package com.example.atelier_closet

import android.graphics.Bitmap
import android.net.Uri
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.segmentation.subject.SubjectSegmentation
import com.google.mlkit.vision.segmentation.subject.SubjectSegmenterOptions
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "atelier_closet/background_removal"
        ).setMethodCallHandler { call, result ->
            if (call.method != "removeBackground") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val imagePath = call.argument<String>("imagePath")
            if (imagePath.isNullOrBlank()) {
                result.success(null)
                return@setMethodCallHandler
            }

            try {
                val inputImage = InputImage.fromFilePath(this, Uri.fromFile(File(imagePath)))
                val options = SubjectSegmenterOptions.Builder()
                    .enableForegroundBitmap()
                    .build()
                val segmenter = SubjectSegmentation.getClient(options)
                segmenter.process(inputImage)
                    .addOnSuccessListener { segmentationResult ->
                        val bitmap = segmentationResult.foregroundBitmap
                        segmenter.close()
                        if (bitmap != null) {
                            val stream = ByteArrayOutputStream()
                            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                            result.success(stream.toByteArray())
                        } else {
                            result.success(null)
                        }
                    }
                    .addOnFailureListener {
                        segmenter.close()
                        result.success(null)
                    }
            } catch (_: Exception) {
                result.success(null)
            }
        }
    }
}
