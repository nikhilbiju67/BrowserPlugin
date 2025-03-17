# Browser Plugin

A Flutter plugin that allows you to open a custom browser window within your application. This plugin is especially useful for handling payment gateways, authentication flows, or any scenario where you need to interact with web content within your Flutter app.

## Features

- **Custom Browser View:** Open a web URL in a dedicated browser-like view.
- **URL Change Callback:** Listen for changes in the URL during navigation.
- **Finish Callback:** Trigger an event when the browser is closed or a specific URL is reached.
- **WebView Auto-Close:** Automatically close the browser when a specified URL is loaded.

## Getting Started

### Installation

To use the browser plugin in your Flutter project, add it as a dependency in your `pubspec.yaml`:

```yaml
dependencies:
  browser_plugin: ^x.y.z
  ```
Replace x.y.z with the latest version of the plugin. Then, run:

```flutter pub get

 ```

Below is a sample usage of the plugin. This example demonstrates how to open a browser window when a floating action button is pressed, listen for URL changes, and handle the browser close event:


```import 'package:browser_plugin/browser_plugin.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            BrowserPlugin paymentBrowser = BrowserPlugin(
              onUrlChange: (url) {
                // Handle URL change events here.
                print('URL changed: $url');
              },
              onFinishCallback: () {
                // Handle browser finish/close event here.
                print('Browser closed');
              },
              url: "https://www.google.com/",
              webViewCloseUrl: "https://confirm-payment/",
            );
            paymentBrowser.open();
          },
        ),
        appBar: AppBar(
          title: const Text('Plugin Example App'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
```

