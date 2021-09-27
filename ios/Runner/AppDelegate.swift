import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    let midiPlayer = MidiPlayer()
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let midiChannel = FlutterMethodChannel(name: "midi.partmaster.de/player",
                                              binaryMessenger: controller.binaryMessenger)
    midiChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      if call.method == "play" {
        self?.midiPlayer.play()
        result("Player.play()")
        return
      }
      else if call.method == "pause" {
        self?.midiPlayer.stop()
          result("Player.pause()")
          return
        }
      else if call.method == "load" {
        guard let arguments = call.arguments as? Dictionary<String, Any> else {
            result("Player.load(): arguments is no Dictionary")
            return
        }
        guard let uri = arguments["uri"] as? String else {
            result("Player.load(): no uri in arguments")
            return
        }
        guard let url = URL(string: uri) else {
            result("Player.load(): uri is no URL")
            return
        }
        self?.midiPlayer.load(url: url)
          result("Player.load($uri) success")
          return
        }
      else if call.method == "position" {
        guard let position = self?.midiPlayer.position() else {
          result(0)
          return
        }
          result(position)
          return
        }
      else if call.method == "dispose" {
          result(FlutterMethodNotImplemented)
          return
        }
      else {
          result(FlutterError(code: "UNAVAILABLE",
                              message: "unknown midi player method \(call.method)",
                        details: nil))
      }
    })
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
