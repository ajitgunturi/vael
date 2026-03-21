import Flutter
import Foundation

/// Platform channel handler for iCloud Drive operations on iOS.
class ICloudPlugin: NSObject, FlutterPlugin {
    static let channelName = "com.vael.vael/icloud"
    static let containerIdentifier = "iCloud.com.vael.vael"

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: registrar.messenger()
        )
        let instance = ICloudPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getContainerPath":
            getContainerPath(result: result)
        case "isAvailable":
            isAvailable(result: result)
        case "startDownloading":
            guard let args = call.arguments as? [String: Any],
                  let path = args["path"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "path required", details: nil))
                return
            }
            startDownloading(path: path, result: result)
        case "isFileLocal":
            guard let args = call.arguments as? [String: Any],
                  let path = args["path"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "path required", details: nil))
                return
            }
            isFileLocal(path: path, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func getContainerPath(result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let containerURL = FileManager.default.url(
                forUbiquityContainerIdentifier: ICloudPlugin.containerIdentifier
            ) else {
                DispatchQueue.main.async { result(nil) }
                return
            }
            // Ensure the Documents subdirectory exists
            let documentsURL = containerURL.appendingPathComponent("Documents")
            try? FileManager.default.createDirectory(
                at: documentsURL,
                withIntermediateDirectories: true
            )
            DispatchQueue.main.async { result(documentsURL.path) }
        }
    }

    private func isAvailable(result: @escaping FlutterResult) {
        let available = FileManager.default.ubiquityIdentityToken != nil
        result(available)
    }

    private func startDownloading(path: String, result: @escaping FlutterResult) {
        let fileURL = URL(fileURLWithPath: path)
        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: fileURL)
            result(true)
        } catch {
            result(false)
        }
    }

    private func isFileLocal(path: String, result: @escaping FlutterResult) {
        let fileURL = URL(fileURLWithPath: path)
        var isDownloaded: AnyObject?
        do {
            try (fileURL as NSURL).getResourceValue(
                &isDownloaded,
                forKey: .ubiquitousItemDownloadingStatusKey
            )
            if let status = isDownloaded as? URLResourceValues {
                result(true)
            } else {
                // Check if file simply exists locally
                result(FileManager.default.fileExists(atPath: path))
            }
        } catch {
            result(FileManager.default.fileExists(atPath: path))
        }
    }
}
