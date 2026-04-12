import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Compresses captured/picked images for faster upload.
///
/// Settings: JPEG 85% quality, max 1920x1920.
class ImageCompressor {
  ImageCompressor._();

  static const int _compressQuality = 85;
  static const int _compressMaxWidth = 1920;
  static const int _compressMaxHeight = 1920;

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
}
