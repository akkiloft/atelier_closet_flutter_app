import CoreImage
import Flutter
import UIKit
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let registrar = self.registrar(forPlugin: "BackgroundRemovalChannel") {
      let channel = FlutterMethodChannel(
        name: "atelier_closet/background_removal",
        binaryMessenger: registrar.messenger()
      )
      channel.setMethodCallHandler { call, result in
        guard call.method == "removeBackground",
              let args = call.arguments as? [String: Any],
              let imagePath = args["imagePath"] as? String else {
          result(FlutterMethodNotImplemented)
          return
        }
        Self.removeBackground(imagePath: imagePath, result: result)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private static func removeBackground(imagePath: String, result: @escaping FlutterResult) {
    guard #available(iOS 17.0, *) else {
      result(nil)
      return
    }

    DispatchQueue.global(qos: .userInitiated).async {
      let imageUrl = URL(fileURLWithPath: imagePath)
      let request = VNGenerateForegroundInstanceMaskRequest()
      let handler = VNImageRequestHandler(url: imageUrl, options: [:])

      do {
        try handler.perform([request])
        guard let observation = request.results?.first,
              !observation.allInstances.isEmpty else {
          DispatchQueue.main.async { result(nil) }
          return
        }

        let maskedBuffer = try observation.generateMaskedImage(
          ofInstances: observation.allInstances,
          from: handler,
          croppedToInstancesExtent: true
        )
        let outputCI = CIImage(cvPixelBuffer: maskedBuffer)
        let context = CIContext()
        guard let outputCG = context.createCGImage(outputCI, from: outputCI.extent),
              let pngData = UIImage(cgImage: outputCG).pngData() else {
          DispatchQueue.main.async { result(nil) }
          return
        }

        DispatchQueue.main.async {
          result(FlutterStandardTypedData(bytes: pngData))
        }
      } catch {
        DispatchQueue.main.async { result(nil) }
      }
    }
  }
}
