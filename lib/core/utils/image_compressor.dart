import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../config/app_config.dart';
import '../errors/app_exception.dart';

/// Result of preparing an image for AI analysis / optional storage.
class PreparedImage {
  PreparedImage({
    required this.bytes,
    required this.mimeType,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final String mimeType;
  final int width;
  final int height;

  late final String base64 = base64Encode(bytes);
}

/// Compresses, resizes, re-orients (EXIF) and normalizes an input image.
/// Rejects images that remain over the configured byte limit after
/// compression. Strips metadata by re-encoding to a fresh JPEG.
class ImageCompressor {
  const ImageCompressor();

  Future<PreparedImage> prepare(Uint8List input) async {
    final img.Image? decoded = img.decodeImage(input);
    if (decoded == null) {
      throw const AppException(AppErrorKind.invalidInput,
          debugDetail: 'undecodable image');
    }

    // Bake in EXIF orientation, then drop metadata by re-encoding.
    img.Image oriented = img.bakeOrientation(decoded);

    final int longest =
        oriented.width > oriented.height ? oriented.width : oriented.height;
    if (longest > AppConfig.maxImageDimension) {
      final double scale = AppConfig.maxImageDimension / longest;
      oriented = img.copyResize(
        oriented,
        width: (oriented.width * scale).round(),
        height: (oriented.height * scale).round(),
        interpolation: img.Interpolation.average,
      );
    }

    final Uint8List jpeg = Uint8List.fromList(
      img.encodeJpg(oriented, quality: AppConfig.imageJpegQuality),
    );

    if (jpeg.lengthInBytes > AppConfig.maxImageBytes) {
      throw const AppException(AppErrorKind.imageTooLarge);
    }

    return PreparedImage(
      bytes: jpeg,
      mimeType: 'image/jpeg',
      width: oriented.width,
      height: oriented.height,
    );
  }
}
