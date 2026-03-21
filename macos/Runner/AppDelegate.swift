import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller = NSApplication.shared.mainWindow?.contentViewController as? FlutterViewController
    if let registrar = controller?.registrar(forPlugin: "ICloudPlugin") {
      ICloudPlugin.register(with: registrar)
    }
  }
}
