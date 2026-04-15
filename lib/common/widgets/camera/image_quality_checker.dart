import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Compresses captured/picked images for faster upload and to stay under the
/// server's request-size limit (nginx `client_max_body_size`).
///
/// First pass: JPEG 75% quality, max 1600x1600. If still over [_targetMaxBytes],
/// escalates through lower quality / smaller dimensions until it fits.
class ImageCompressor {
  ImageCompressor._();

  // ~900KB — leaves headroom under a 1MB server cap for multipart overhead.
  static const int _targetMaxBytes = 900 * 1024;

  // Escalating (quality, minSide) passes, from lightest to most aggressive.
  static const List<(int quality, int minSide)> _passes = [
    (75, 1600),
    (60, 1280),
    (45, 1024),
  ];

  /// Compresses [imageFile], retrying with stronger settings until the output
  /// is under [maxBytes]. Returns the smallest successful output, or the
  /// original if every pass fails.
  static Future<File> compress(File imageFile, {int? maxBytes}) async {
    final limit = maxBytes ?? _targetMaxBytes;
    File? best;

    for (var i = 0; i < _passes.length; i++) {
      final (quality, minSide) = _passes[i];
      final out = await _runPass(imageFile, quality, minSide, i);
      if (out == null) continue;

      final size = out.lengthSync();
      if (best == null || size < best.lengthSync()) best = out;
      if (size <= limit) return out;
    }

    return best ?? imageFile;
  }

  static Future<File?> _runPass(
    File input,
    int quality,
    int minSide,
    int passIndex,
  ) async {
    try {
      final target =
          '${input.parent.path}/compressed_${passIndex}_${input.uri.pathSegments.last}';
      final result = await FlutterImageCompress.compressAndGetFile(
        input.absolute.path,
        target,
        quality: quality,
        minWidth: minSide,
        minHeight: minSide,
        format: CompressFormat.jpeg,
      );
      return result != null ? File(result.path) : null;
    } catch (_) {
      return null;
    }
  }
}
