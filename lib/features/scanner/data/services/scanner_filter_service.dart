import 'dart:math';
import 'package:image/image.dart' as img;
import '../models/scanner_filter_type.dart';

class ScannerFilterService {
  /// Applies the selected filter to [inputImage] and returns a new transformed image.
  static img.Image applyFilter(img.Image inputImage, ScannerFilterType filterType) {
    switch (filterType) {
      case ScannerFilterType.original:
        return inputImage;
      case ScannerFilterType.auto:
        return _applyAuto(inputImage);
      case ScannerFilterType.enhanced:
        return _applyEnhanced(inputImage);
      case ScannerFilterType.grayscale:
        return _applyGrayscale(inputImage);
      case ScannerFilterType.bw:
        return _applyBW(inputImage);
      case ScannerFilterType.shadow:
        return _applyShadowReduction(inputImage);
    }
  }

  /// Auto filter: Mild contrast boost, brightness optimization & light sharpening
  static img.Image _applyAuto(img.Image src) {
    final w = src.width;
    final h = src.height;
    final out = img.Image.from(src);

    const double contrast = 1.25;
    const double brightness = 12.0;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final p = src.getPixel(x, y);

        num r = (((p.r - 128) * contrast) + 128 + brightness).clamp(0, 255);
        num g = (((p.g - 128) * contrast) + 128 + brightness).clamp(0, 255);
        num b = (((p.b - 128) * contrast) + 128 + brightness).clamp(0, 255);

        out.setPixelRgb(x, y, r.toInt(), g.toInt(), b.toInt());
      }
    }
    return out;
  }

  /// Enhanced filter: Stronger document contrast, background whitening
  static img.Image _applyEnhanced(img.Image src) {
    final w = src.width;
    final h = src.height;
    final out = img.Image.from(src);

    const double contrast = 1.42;
    const double brightness = 18.0;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final p = src.getPixel(x, y);

        final lum = 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;

        double r = (((p.r - 128) * contrast) + 128 + brightness);
        double g = (((p.g - 128) * contrast) + 128 + brightness);
        double b = (((p.b - 128) * contrast) + 128 + brightness);

        // Push high luminance background pixels towards pure white
        if (lum > 185) {
          final factor = (lum - 185) / 70.0;
          r = r + (255 - r) * factor;
          g = g + (255 - g) * factor;
          b = b + (255 - b) * factor;
        }

        out.setPixelRgb(
          x,
          y,
          r.clamp(0, 255).toInt(),
          g.clamp(0, 255).toInt(),
          b.clamp(0, 255).toInt(),
        );
      }
    }
    return out;
  }

  /// Grayscale filter
  static img.Image _applyGrayscale(img.Image src) {
    final w = src.width;
    final h = src.height;
    final out = img.Image(width: w, height: h);

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final p = src.getPixel(x, y);
        final gray = (0.299 * p.r + 0.587 * p.g + 0.114 * p.b).round();
        final adjusted = (((gray - 128) * 1.2) + 128 + 8).clamp(0, 255).toInt();

        out.setPixelRgb(x, y, adjusted, adjusted, adjusted);
      }
    }
    return out;
  }

  /// B&W filter: High-contrast adaptive local thresholding
  static img.Image _applyBW(img.Image src) {
    final w = src.width;
    final h = src.height;
    final out = img.Image(width: w, height: h);

    final gray = List<int>.filled(w * h, 0);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final p = src.getPixel(x, y);
        gray[y * w + x] = (0.299 * p.r + 0.587 * p.g + 0.114 * p.b).round();
      }
    }

    // Adaptive grid block mean calculation
    const blockSize = 24;
    final gridW = (w / blockSize).ceil();
    final gridH = (h / blockSize).ceil();
    final gridMeans = List<double>.filled(gridW * gridH, 128.0);

    for (int gy = 0; gy < gridH; gy++) {
      for (int gx = 0; gx < gridW; gx++) {
        int sum = 0;
        int count = 0;
        final startX = gx * blockSize;
        final startY = gy * blockSize;
        final endX = min(startX + blockSize, w);
        final endY = min(startY + blockSize, h);

        for (int y = startY; y < endY; y++) {
          for (int x = startX; x < endX; x++) {
            sum += gray[y * w + x];
            count++;
          }
        }
        gridMeans[gy * gridW + gx] = count > 0 ? sum / count : 128.0;
      }
    }

    for (int y = 0; y < h; y++) {
      final gy = (y / blockSize).floor().clamp(0, gridH - 1);
      for (int x = 0; x < w; x++) {
        final gx = (x / blockSize).floor().clamp(0, gridW - 1);
        final localMean = gridMeans[gy * gridW + gx];

        final val = gray[y * w + x];
        final threshold = localMean - 8;

        final isWhite = val >= threshold;
        final color = isWhite ? 255 : 0;
        out.setPixelRgb(x, y, color, color, color);
      }
    }

    return out;
  }

  /// Shadow Reduction filter: Division by background illumination map
  static img.Image _applyShadowReduction(img.Image src) {
    final w = src.width;
    final h = src.height;
    final out = img.Image(width: w, height: h);

    // Compute downsampled background luminance grid
    const step = 16;
    final gridW = (w / step).ceil();
    final gridH = (h / step).ceil();
    final bgGrid = List<double>.filled(gridW * gridH, 200.0);

    for (int gy = 0; gy < gridH; gy++) {
      for (int gx = 0; gx < gridW; gx++) {
        double maxLum = 0;
        final startX = gx * step;
        final startY = gy * step;
        final endX = min(startX + step, w);
        final endY = min(startY + step, h);

        for (int y = startY; y < endY; y++) {
          for (int x = startX; x < endX; x++) {
            final p = src.getPixel(x, y);
            final lum = 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
            if (lum > maxLum) maxLum = lum;
          }
        }
        bgGrid[gy * gridW + gx] = maxLum < 30 ? 30 : maxLum;
      }
    }

    for (int y = 0; y < h; y++) {
      final gy = (y / step).floor().clamp(0, gridH - 1);
      for (int x = 0; x < w; x++) {
        final gx = (x / step).floor().clamp(0, gridW - 1);
        final bgLum = bgGrid[gy * gridW + gx];

        final p = src.getPixel(x, y);

        final r = ((p.r / (bgLum + 1.0)) * 240.0).clamp(0, 255).toInt();
        final g = ((p.g / (bgLum + 1.0)) * 240.0).clamp(0, 255).toInt();
        final b = ((p.b / (bgLum + 1.0)) * 240.0).clamp(0, 255).toInt();

        out.setPixelRgb(x, y, r, g, b);
      }
    }

    return out;
  }
}
