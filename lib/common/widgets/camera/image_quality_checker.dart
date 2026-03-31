import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'image_quality_result.dart';

/// Analyzes a captured photo for brightness, overexposure, and blur,
/// then compresses the image for faster upload.
///
/// Pipeline:
/// 1. Decode the JPEG at 256px (native, fast) and extract raw RGBA pixels.
/// 2. Ship the pixel buffer to [compute] for brightness + blur analysis.
/// 3. If quality passes, compress the original image via native JPEG encoder.
class ImageQualityChecker {
  ImageQualityChecker._();

  static const int _analysisWidth = 256;

  // Brightness thresholds (0-255 luminance scale)
  static const double _darkThreshold = 45.0;
  static const double _brightThreshold = 215.0;

  // Overexposure: fraction of pixels with luminance > 240
  static const double _overexposurePixelThreshold = 240.0;
  static const double _overexposureRatio = 0.25;

  // Blur: Laplacian variance below this is considered blurry
  static const double _blurThreshold = 80.0;

  // Compression settings
  static const int _compressQuality = 85;
  static const int _compressMaxWidth = 1920;
  static const int _compressMaxHeight = 1920;

  /// Runs quality analysis on [imageFile].
  static Future<ImageQualityResult> analyze(File imageFile) async {
    final bytes = await imageFile.readAsBytes();

    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: _analysisWidth,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

    if (byteData == null) return ImageQualityResult.clean;

    final pixels = byteData.buffer.asUint8List();
    final width = image.width;
    final height = image.height;
    image.dispose();

    return compute(
      _analyzePixels,
      _PixelPayload(pixels: pixels, width: width, height: height),
    );
  }

  /// Compresses [imageFile] using the native JPEG encoder.
  /// Returns the compressed file, or the original if compression fails.
  static Future<File> compress(File imageFile) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        '${imageFile.parent.path}/compressed_${imageFile.uri.pathSegments.last}',
        quality: _compressQuality,
        minWidth: _compressMaxWidth,
        minHeight: _compressMaxHeight,
        format: CompressFormat.jpeg,
      );
      if (result != null) {
        return File(result.path);
      }
    } catch (_) {
      // Native compression failed — fall back to original
    }
    return imageFile;
  }

  /// Pure computation — safe to run in an isolate.
  static ImageQualityResult _analyzePixels(_PixelPayload payload) {
    final pixels = payload.pixels;
    final width = payload.width;
    final height = payload.height;
    final totalPixels = width * height;

    if (totalPixels == 0) return ImageQualityResult.clean;

    // --- Build grayscale buffer & gather brightness stats ---
    final gray = Uint8List(totalPixels);
    double luminanceSum = 0;
    int overexposedCount = 0;

    for (int i = 0; i < totalPixels; i++) {
      final offset = i * 4; // RGBA
      final r = pixels[offset];
      final g = pixels[offset + 1];
      final b = pixels[offset + 2];

      // ITU-R BT.601 luminance
      final lum = 0.299 * r + 0.587 * g + 0.114 * b;
      gray[i] = lum.round().clamp(0, 255);
      luminanceSum += lum;

      if (lum > _overexposurePixelThreshold) overexposedCount++;
    }

    final avgBrightness = luminanceSum / totalPixels;
    final overexposurePercent = overexposedCount / totalPixels;

    final isDark = avgBrightness < _darkThreshold;
    final isBright =
        avgBrightness > _brightThreshold ||
        overexposurePercent > _overexposureRatio;

    // --- Blur detection: Laplacian variance ---
    final blurScore = _laplacianVariance(gray, width, height);
    final isBlurry = blurScore < _blurThreshold;

    return ImageQualityResult(
      isDark: isDark,
      isBright: isBright,
      isBlurry: isBlurry,
      brightnessScore: avgBrightness,
      blurScore: blurScore,
    );
  }

  /// Computes the variance of the Laplacian over the grayscale image.
  /// Low variance = lack of edges = blurry.
  static double _laplacianVariance(Uint8List gray, int w, int h) {
    if (w < 3 || h < 3) return 999;

    double sum = 0;
    double sumSq = 0;
    int count = 0;

    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        final center = gray[y * w + x];
        final top = gray[(y - 1) * w + x];
        final bottom = gray[(y + 1) * w + x];
        final left = gray[y * w + (x - 1)];
        final right = gray[y * w + (x + 1)];

        final lap = (top + bottom + left + right - 4 * center).toDouble();
        sum += lap;
        sumSq += lap * lap;
        count++;
      }
    }

    if (count == 0) return 999;

    final mean = sum / count;
    return (sumSq / count) - (mean * mean);
  }
}

/// Payload sent to the isolate.
class _PixelPayload {
  final Uint8List pixels;
  final int width;
  final int height;

  const _PixelPayload({
    required this.pixels,
    required this.width,
    required this.height,
  });
}
