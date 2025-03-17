import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'browser_plugin_method_channel.dart';

abstract class BrowserPluginPlatform extends PlatformInterface {
  /// Constructs a BrowserPluginPlatform.
  BrowserPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static BrowserPluginPlatform _instance = MethodChannelBrowserPlugin();

  /// The default instance of [BrowserPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelBrowserPlugin].
  static BrowserPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BrowserPluginPlatform] when
  /// they register themselves.
  static set instance(BrowserPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
