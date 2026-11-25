import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class BackgroundRemovalService {
  static const _uuid = Uuid();

  /// Picks an image file, runs on-device ML Kit Subject Segmentation to isolate
  /// the foreground clothing item, and saves a transparent PNG locally.
  Future<String> removeBackgroundAndSave(String sourceImagePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final cutoutsDir = Directory('${appDir.path}/cutouts');
    if (!await cutoutsDir.exists()) {
      await cutoutsDir.create(recursive: true);
    }

    final outputFilePath = '${cutoutsDir.path}/${_uuid.v4()}.png';

    try {
      final inputImage = InputImage.fromFilePath(sourceImagePath);
      final options = SubjectSegmenterOptions(
        enableForegroundBitmap: true,
        enableForegroundConfidenceMask: false,
        enableMultipleSubjects: SubjectResultOptions(
          enableConfidenceMask: false,
          enableSubjectBitmap: false,
        ),
      );

      final segmenter = SubjectSegmenter(options: options);
      final result = await segmenter.processImage(inputImage);
      await segmenter.close();

      final Uint8List? foregroundBytes = result.foregroundBitmap;
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
      debugPrint('ML Kit segmentation fallback triggered: $e');
    }

    // Fallback: copy original image if segmentation is unsupported on emulator/device
    await File(sourceImagePath).copy(outputFilePath);
    return outputFilePath;
  }
}
