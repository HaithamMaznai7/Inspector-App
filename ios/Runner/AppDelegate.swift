import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // Register native OBD BLE write bridge (bypasses flutter_blue_plus's
    // property validation for WriteWithoutResponse on the BT5050 chip).
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ObdBleWritePlugin") {
      ObdBleWritePlugin.register(with: registrar)
    }
  }
}
