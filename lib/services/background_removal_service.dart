import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class BackgroundRemovalService {
  static const _uuid = Uuid();
  static const _channel = MethodChannel('atelier_closet/background_removal');

  /// Isolates the foreground clothing item using platform-native segmentation
  /// (Apple Vision on iOS 17+, Google ML Kit Subject Segmentation on Android)
  /// and saves a transparent PNG locally.
  Future<String> removeBackgroundAndSave(String sourceImagePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final cutoutsDir = Directory('${appDir.path}/cutouts');
    if (!await cutoutsDir.exists()) {
      await cutoutsDir.create(recursive: true);
    }

    final outputFilePath = '${cutoutsDir.path}/${_uuid.v4()}.png';

    try {
      final Uint8List? foregroundBytes = await _channel.invokeMethod<Uint8List>(
        'removeBackground',
        {'imagePath': sourceImagePath},
      );
      if (foregroundBytes != null && foregroundBytes.isNotEmpty) {
        final decoded = img.decodeImage(foregroundBytes);
        if (decoded != null) {
          final trimmed = img.trim(decoded, mode: img.TrimMode.transparent);
          final pngBytes = img.encodePng(trimmed);
          await File(outputFilePath).writeAsBytes(pngBytes);
          return outputFilePath;
        }
      }
    } catch (e) {
      debugPrint('Background removal fallback triggered: $e');
    }

    // Fallback: copy original image if segmentation is unsupported on device/OS
    await File(sourceImagePath).copy(outputFilePath);
    return outputFilePath;
  }
}
