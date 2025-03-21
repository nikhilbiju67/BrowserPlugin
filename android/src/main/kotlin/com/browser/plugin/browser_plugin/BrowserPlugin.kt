package com.browser.plugin.browser_plugin

import android.app.Activity
import android.content.Intent

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** BrowserPlugin */
class BrowserPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    companion object {
        lateinit var methodChannel: MethodChannel
    }

    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel =
            MethodChannel(flutterPluginBinding.binaryMessenger, "payment_browser_channel")
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "openWebView") {
            val url = call.argument<String>("url")
            val webViewCloseUrl = call.argument<String>("webViewCloseUrl")

            if (activity == null) {
                result.error("NO_ACTIVITY", "Activity is null", null)
                return
            }

            if (url == null || webViewCloseUrl == null) {
                result.error("invalid_arguments", "paymentUrl or redirectUrl is null", null)
                return
            }

            val intent = Intent(activity, WebViewActivity::class.java).apply {
                putExtra("url", url)
                putExtra("webViewCloseUrl", webViewCloseUrl)
            }

            activity?.startActivity(intent)
            result.success(null)
        } else if (call.method == "closeWebView") {
            activity?.finish()
            result.success(null)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
