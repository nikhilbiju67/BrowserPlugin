import Flutter
import UIKit

public class BrowserPlugin: NSObject, FlutterPlugin {

    static var methodChannel: FlutterMethodChannel?
    static var webViewController: WebViewController?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "payment_browser_channel", binaryMessenger: registrar.messenger())
        let instance = BrowserPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        methodChannel = channel
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "openWebView" {
            guard let args = call.arguments as? [String: Any],
                  let paymentUrl = args["url"] as? String,
                  let redirectUrl = args["webViewCloseUrl"] as? String,
                  let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing arguments", details: nil))
                return
            }

            let webViewController = WebViewController()
            webViewController.url = paymentUrl
            webViewController.redirectUrl = redirectUrl
            webViewController.modalPresentationStyle = .fullScreen
            rootViewController.present(webViewController, animated: true, completion: nil)

            // Store reference for later closure
            BrowserPlugin.webViewController = webViewController

            result(nil) // Return success to Flutter

        } else if call.method == "closeWebView" {
            // Close the WebView if it's open
            if let webViewController = BrowserPlugin.webViewController {
                webViewController.dismiss(animated: true, completion: {
                    BrowserPlugin.webViewController = nil // Clear reference
                    self.sendWebViewClosedEvent() // Notify Flutter
                })
            }
            result(nil)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    private func sendWebViewClosedEvent() {
        BrowserPlugin.methodChannel?.invokeMethod("paymentCompleted", arguments: nil)
    }
}

