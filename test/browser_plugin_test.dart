import 'package:flutter_test/flutter_test.dart';
import 'package:browser_plugin/browser_plugin_platform_interface.dart';
import 'package:browser_plugin/browser_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBrowserPluginPlatform
    with MockPlatformInterfaceMixin
    implements BrowserPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BrowserPluginPlatform initialPlatform = BrowserPluginPlatform.instance;

  test('$MethodChannelBrowserPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBrowserPlugin>());
  });

  test('getPlatformVersion', () async {
    // BrowserPlugin browserPlugin = BrowserPlugin();
    // MockBrowserPluginPlatform fakePlatform = MockBrowserPluginPlatform();
    // BrowserPluginPlatform.instance = fakePlatform;
    //
    // expect(await browserPlugin.getPlatformVersion(), '42');
  });
}
