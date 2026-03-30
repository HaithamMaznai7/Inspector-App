import 'dart:io';

import 'package:fahis_inspector/main.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImageQualityResult {
  final bool isDark;
  final bool isBright;
  final bool mayBeBlurry;
  final double luminance;
  final double laplacianVariance;

  const ImageQualityResult({
    this.isDark = false,
    this.isBright = false,
    this.mayBeBlurry = false,
    this.luminance = 0,
    this.laplacianVariance = 0,
  });

  bool get hasWarning => isDark || isBright || mayBeBlurry;
}

class ImageQualityChecker {
  static const int _analysisSize = 256;
  static const double _darkThreshold = 40;
  static const double _brightThreshold = 230;
  static const double _blurThreshold = 500;

  /// Analyzes a captured photo for basic quality issues.
  /// Runs in a background isolate to avoid blocking the UI.
  static Future<ImageQualityResult> check(File file) async {
    try {
      final fileSize = await file.length();
      dd('ImageQuality — START | fileSize=${(fileSize / 1024).toStringAsFixed(0)} KB');

      final bytes = await file.readAsBytes();
      final result = await compute(_analyzeBytes, bytes);

      dd('ImageQuality — DONE | luminance=${result.luminance.toStringAsFixed(1)} '
          '| laplacian=${result.laplacianVariance.toStringAsFixed(1)} '
          '| dark=${result.isDark} | bright=${result.isBright} | blur=${result.mayBeBlurry}');

      return result;
    } catch (e) {
      dd('ImageQuality — ERROR: $e');
      return const ImageQualityResult();
    }
  }

  /// Runs entirely in a background isolate — no main thread blocking.
  static ImageQualityResult _analyzeBytes(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return const ImageQualityResult();
    }

    final small = img.copyResize(
      decoded,
      width: _analysisSize,
      height: _analysisSize,
    );

    final meanLuminance = _computeMeanLuminance(small);
    final laplacianVar = _computeLaplacianVariance(small);

    return ImageQualityResult(
      isDark: meanLuminance < _darkThreshold,
      isBright: meanLuminance > _brightThreshold,
      mayBeBlurry: laplacianVar < _blurThreshold,
      luminance: meanLuminance,
      laplacianVariance: laplacianVar,
    );
  }

  /// Mean luminance (0-255) across all pixels.
  static double _computeMeanLuminance(img.Image image) {
    double sum = 0;
    final pixelCount = image.width * image.height;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        sum += 0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b;
      }
    }

    return sum / pixelCount;
  }

  /// Laplacian variance — higher = sharper, lower = blurrier.
  static double _computeLaplacianVariance(img.Image image) {
    final w = image.width;
    final h = image.height;
    if (w < 3 || h < 3) return double.infinity;

    final gray = Float64List(w * h);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final pixel = image.getPixel(x, y);
        gray[y * w + x] = 0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b;
      }
    }

    double sum = 0;
    double sumSq = 0;
    int count = 0;

    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        final lap = -4 * gray[y * w + x] +
            gray[(y - 1) * w + x] +
            gray[(y + 1) * w + x] +
            gray[y * w + (x - 1)] +
            gray[y * w + (x + 1)];
        sum += lap;
        sumSq += lap * lap;
        count++;
      }
    }

    final mean = sum / count;
    return (sumSq / count) - (mean * mean);
  }
}
