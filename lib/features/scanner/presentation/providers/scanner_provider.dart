import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/scanner_filter_type.dart';
import '../../data/models/scanner_page_model.dart';
import '../../data/services/document_detection_service.dart';
import '../../data/services/perspective_transform_service.dart';
import '../../data/services/scanner_filter_service.dart';
import '../../data/services/scanner_storage_service.dart';

class ScannerProvider extends ChangeNotifier {
  final List<ScannerPageModel> _pages = [];
  int _currentIndex = 0;

  bool _isLoading = false;
  String? _loadingMessage;

  // Cached rendered preview path for each page ID
  final Map<String, String> _previewCache = {};

  List<ScannerPageModel> get pages => List.unmodifiable(_pages);
  int get currentIndex => _currentIndex;
  int get totalPages => _pages.length;

  bool get isLoading => _isLoading;
  String? get loadingMessage => _loadingMessage;

  ScannerPageModel? get currentPage =>
      (_pages.isNotEmpty && _currentIndex >= 0 && _currentIndex < _pages.length)
          ? _pages[_currentIndex]
          : null;

  String? get currentPreviewPath =>
      currentPage != null ? _previewCache[currentPage!.id] : null;

  /// Initializes a new scanning session from selected gallery image paths.
  Future<void> initSession(List<String> imagePaths) async {
    _isLoading = true;
    _loadingMessage = 'Processing selected image(s)...';
    notifyListeners();

    _pages.clear();
    _previewCache.clear();
    _currentIndex = 0;

    const uuid = Uuid();

    for (int i = 0; i < imagePaths.length; i++) {
      final path = imagePaths[i];
      _loadingMessage = 'Analyzing document ${i + 1} of ${imagePaths.length}...';
      notifyListeners();

      try {
        final bytes = await File(path).readAsBytes();
        final decoded = await compute(_decodeAndBake, bytes);

        if (decoded != null) {
          // Detect document corners
          final detectionResult = await compute(DocumentDetectionService.detectDocument, decoded);

          final page = ScannerPageModel(
            id: uuid.v4(),
            originalImagePath: path,
            corners: detectionResult.corners,
            rotationAngle: 0,
            selectedFilter: ScannerFilterType.auto,
            isDetected: detectionResult.isHighConfidence,
          );

          _pages.add(page);

          // Render initial preview
          final previewPath = await _renderPreviewForPage(page, decoded);
          if (previewPath != null) {
            _previewCache[page.id] = previewPath;
          }
        }
      } catch (e) {
        debugPrint('Error initializing page $i: $e');
      }
    }

    _isLoading = false;
    _loadingMessage = null;
    notifyListeners();
  }

  /// Updates corners for a page and re-renders preview
  Future<void> updateCorners(int pageIndex, List<Offset> corners) async {
    if (pageIndex < 0 || pageIndex >= _pages.length) return;

    _pages[pageIndex] = _pages[pageIndex].copyWith(corners: corners);
    notifyListeners();

    await _refreshCurrentPreview();
  }

  /// Rotates current page 90 degrees right
  Future<void> rotateCurrentPageRight() async {
    if (currentPage == null) return;
    final newAngle = (currentPage!.rotationAngle + 90) % 360;
    _pages[_currentIndex] = currentPage!.copyWith(rotationAngle: newAngle);
    notifyListeners();

    await _refreshCurrentPreview();
  }

  /// Rotates current page 90 degrees left
  Future<void> rotateCurrentPageLeft() async {
    if (currentPage == null) return;
    final newAngle = (currentPage!.rotationAngle - 90 + 360) % 360;
    _pages[_currentIndex] = currentPage!.copyWith(rotationAngle: newAngle);
    notifyListeners();

    await _refreshCurrentPreview();
  }

  /// Updates current page filter and re-renders preview
  Future<void> setFilterForCurrentPage(ScannerFilterType filter) async {
    if (currentPage == null || currentPage!.selectedFilter == filter) return;
    _pages[_currentIndex] = currentPage!.copyWith(selectedFilter: filter);
    notifyListeners();

    await _refreshCurrentPreview();
  }

  /// Navigates to page by index
  void goToPage(int index) {
    if (index >= 0 && index < _pages.length) {
      _currentIndex = index;
      notifyListeners();
      if (!_previewCache.containsKey(currentPage?.id)) {
        _refreshCurrentPreview();
      }
    }
  }

  void nextPage() {
    if (_currentIndex < _pages.length - 1) {
      goToPage(_currentIndex + 1);
    }
  }

  void previousPage() {
    if (_currentIndex > 0) {
      goToPage(_currentIndex - 1);
    }
  }

  /// Re-renders preview for current active page
  Future<void> _refreshCurrentPreview() async {
    final page = currentPage;
    if (page == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final bytes = await File(page.originalImagePath).readAsBytes();
      final decoded = await compute(_decodeAndBake, bytes);

      if (decoded != null) {
        final oldPath = _previewCache[page.id];

        final previewPath = await _renderPreviewForPage(page, decoded);
        if (previewPath != null) {
          _previewCache[page.id] = previewPath;

          if (oldPath != null && oldPath != previewPath) {
            try {
              final oldFile = File(oldPath);
              if (await oldFile.exists()) {
                await oldFile.delete();
              }
              await FileImage(oldFile).evict();
            } catch (e) {
              debugPrint('Error cleaning old preview: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error refreshing preview: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Saves all pages in session to device storage
  Future<List<String>> saveSession({
    required String baseName,
    required OutputFormat format,
    int quality = 85,
    required void Function(int current, int total) onProgress,
  }) async {
    final savedPaths = <String>[];

    for (int i = 0; i < _pages.length; i++) {
      onProgress(i + 1, _pages.length);

      final page = _pages[i];
      try {
        final bytes = await File(page.originalImagePath).readAsBytes();
        final decoded = await compute(_decodeAndBake, bytes);

        if (decoded != null) {
          // Render full resolution
          final processed = await compute(_processPageFull, _ProcessParams(page, decoded));

          final savedPath = await ScannerStorageService.saveImage(
            image: processed,
            baseName: baseName,
            format: format,
            quality: quality,
            pageIndex: i,
            totalPages: _pages.length,
          );

          if (savedPath != null) {
            savedPaths.add(savedPath);
          }
        }
      } catch (e) {
        debugPrint('Error saving page $i: $e');
      }
    }

    return savedPaths;
  }

  static Future<String?> _renderPreviewForPage(
      ScannerPageModel page, img.Image fullImage) async {
    try {
      // Downscale image for quick preview rendering
      final previewImage = await compute(_processPagePreview, _ProcessParams(page, fullImage));

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/preview_${page.id}_$timestamp.jpg');
      final jpgBytes = img.encodeJpg(previewImage, quality: 80);
      await tempFile.writeAsBytes(jpgBytes, flush: true);

      return tempFile.path;
    } catch (e) {
      debugPrint('Error rendering preview: $e');
      return null;
    }
  }
}

class _ProcessParams {
  final ScannerPageModel page;
  final img.Image image;
  _ProcessParams(this.page, this.image);
}

img.Image? _decodeAndBake(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  return img.bakeOrientation(decoded);
}

img.Image _processPagePreview(_ProcessParams params) {
  final page = params.page;
  var image = params.image;

  // Downscale to max 1000px for preview rendering
  if (image.width > 1000 || image.height > 1000) {
    image = img.copyResize(
      image,
      width: image.width > image.height ? 1000 : null,
      height: image.height >= image.width ? 1000 : null,
    );
  }

  // 1. Perspective Transform
  var transformed = PerspectiveTransformService.transform(
    sourceImage: image,
    normalizedCorners: page.corners,
  );

  // 2. Rotation
  if (page.rotationAngle != 0) {
    transformed = img.copyRotate(transformed, angle: page.rotationAngle);
  }

  // 3. Filter
  return ScannerFilterService.applyFilter(transformed, page.selectedFilter);
}

img.Image _processPageFull(_ProcessParams params) {
  final page = params.page;
  var image = params.image;

  // 1. Perspective Transform at full resolution
  var transformed = PerspectiveTransformService.transform(
    sourceImage: image,
    normalizedCorners: page.corners,
  );

  // 2. Rotation
  if (page.rotationAngle != 0) {
    transformed = img.copyRotate(transformed, angle: page.rotationAngle);
  }

  // 3. Filter
  return ScannerFilterService.applyFilter(transformed, page.selectedFilter);
}
