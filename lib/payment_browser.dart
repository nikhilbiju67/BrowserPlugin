import 'package:flutter/services.dart';

typedef BrowserCompletionCallback = void Function();

typedef UrlChangeCallback = void Function(String url);

class BrowserPlugin {
  static const MethodChannel _channel =
      MethodChannel('payment_browser_channel');

  final String url;
  final String? webViewCloseUrl;
  final BrowserCompletionCallback onFinishCallback;
  final UrlChangeCallback onUrlChange;

  BrowserPlugin({
    required this.url,
    this.webViewCloseUrl,
    required this.onFinishCallback,
    required this.onUrlChange,
  }) {
    _setupMethodHandler();
  }

  void _setupMethodHandler() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "onFinish") {
        onFinishCallback();
      } else if (call.method == "onUrlChanged") {
        final url = call.arguments as String;
        onUrlChange(url);
      }
    });
  }

  Future<void> open() async {
    await _channel.invokeMethod('openWebView', {
      'url': url,
      'webViewCloseUrl': webViewCloseUrl,
    });
  }

  Future<void> close() async {
    await _channel.invokeMethod('closeWebView');
  }
}

abstract class InAppPaymentBrowser {}
