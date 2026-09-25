import 'dart:io';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import '../../../../core/utils/storage_utils.dart';

enum OutputFormat { jpg, png }

class ScannerStorageService {
  /// Generates timestamp string in YYMMDDHHMMSS format (e.g. 260922164012)
  static String generateTimestamp() {
    final now = DateTime.now();
    return DateFormat('yyMMddHHmmss').format(now);
  }

  /// Saves an encoded image to MS Smart Tools directory and device Gallery.
  static Future<String?> saveImage({
    required img.Image image,
    required String baseName,
    required OutputFormat format,
    int quality = 85,
    int? pageIndex,
    int? totalPages,
  }) async {
    try {
      final timestamp = generateTimestamp();
      final extension = format == OutputFormat.jpg ? 'jpg' : 'png';

      // Format filename according to specification:
      // Single page: baseName_YYMMDDHHMMSS.jpg
      // Multi page: baseName_page1_YYMMDDHHMMSS.jpg
      String fileName;
      final cleanBaseName = _sanitizeFileName(baseName);

      if (totalPages != null && totalPages > 1 && pageIndex != null) {
        fileName = '${cleanBaseName}_page${pageIndex + 1}_$timestamp.$extension';
      } else {
        fileName = '${cleanBaseName}_$timestamp.$extension';
      }

      // Encode image
      List<int> bytes;
      if (format == OutputFormat.jpg) {
        bytes = img.encodeJpg(image, quality: quality.clamp(10, 100));
      } else {
        bytes = img.encodePng(image);
      }

      final outputDir = await StorageUtils.getAppOutputDir();
      final targetPath = '$outputDir/$fileName';

      final file = File(targetPath);
      await file.writeAsBytes(bytes, flush: true);

      // Save to Gallery under "MS Smart Tools" album
      await StorageUtils.saveFileToCustomFolder(targetPath, fileName);

      return targetPath;
    } catch (e) {
      return null;
    }
  }

  static String _sanitizeFileName(String name) {
    var s = name.trim();
    if (s.isEmpty) s = 'document';
    // Remove extension if user entered it
    if (s.toLowerCase().endsWith('.jpg') || s.toLowerCase().endsWith('.png') || s.toLowerCase().endsWith('.jpeg')) {
      s = s.substring(0, s.lastIndexOf('.'));
    }
    // Replace invalid filesystem characters
    return s.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }
}
