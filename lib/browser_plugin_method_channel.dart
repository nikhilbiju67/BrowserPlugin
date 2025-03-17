import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'browser_plugin_platform_interface.dart';

/// An implementation of [BrowserPluginPlatform] that uses method channels.
class MethodChannelBrowserPlugin extends BrowserPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('browser_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
