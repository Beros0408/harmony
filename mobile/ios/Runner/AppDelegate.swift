import CallKit
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
    setupCallFilterChannel(engineBridge: engineBridge)
  }

  // MARK: - Call Filter iOS Channel

  private static let channelName = "com.harmony.app/call_filter_ios"

  private func setupCallFilterChannel(engineBridge: FlutterImplicitEngineBridge) {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    let channel = FlutterMethodChannel(
      name: AppDelegate.channelName,
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handleMethodCall(call, result: result)
    }
  }

  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isExtensionEnabled":
      checkExtensionEnabled(result: result)
    case "reloadExtension":
      reloadExtension(result: result)
    case "syncRulesToExtension":
      syncRules(call: call, result: result)
    case "openSettings":
      openSettings(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func checkExtensionEnabled(result: @escaping FlutterResult) {
    CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(
      withIdentifier: "com.harmony.harmony.HarmonyCallDirectoryExtension"
    ) { status, _ in
      DispatchQueue.main.async {
        result(status == .enabled)
      }
    }
  }

  private func reloadExtension(result: @escaping FlutterResult) {
    CXCallDirectoryManager.sharedInstance.reloadExtension(
      withIdentifier: "com.harmony.harmony.HarmonyCallDirectoryExtension"
    ) { error in
      DispatchQueue.main.async {
        if let error = error {
          result(FlutterError(code: "RELOAD_FAILED", message: error.localizedDescription, details: nil))
        } else {
          result(nil)
        }
      }
    }
  }

  private func syncRules(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "INVALID_ARGS", message: "Expected map argument", details: nil))
      return
    }
    let blacklist = args["blacklist"] as? [String] ?? []
    let whitelist = args["whitelist"] as? [String] ?? []
    SharedRulesStore.saveBlacklist(blacklist)
    SharedRulesStore.saveWhitelist(whitelist)
    // Reload so iOS picks up the new numbers immediately
    CXCallDirectoryManager.sharedInstance.reloadExtension(
      withIdentifier: "com.harmony.harmony.HarmonyCallDirectoryExtension"
    ) { error in
      DispatchQueue.main.async {
        if let error = error {
          result(FlutterError(code: "RELOAD_FAILED", message: error.localizedDescription, details: nil))
        } else {
          result(nil)
        }
      }
    }
  }

  private func openSettings(result: @escaping FlutterResult) {
    if let url = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(url)
    }
    result(nil)
  }
}
