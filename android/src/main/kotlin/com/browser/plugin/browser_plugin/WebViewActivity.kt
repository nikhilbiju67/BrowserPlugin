package com.browser.plugin.browser_plugin

import android.annotation.SuppressLint
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import io.flutter.plugin.common.MethodChannel

class WebViewActivity : AppCompatActivity() {

    private lateinit var webView: WebView
    private lateinit var methodChannel: MethodChannel

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Create WebView
        webView = WebView(this)
        setContentView(webView)

        val paymentUrl = intent.getStringExtra("url")
        val redirectUrl = intent.getStringExtra("webViewCloseUrl")

        if (paymentUrl == null || redirectUrl == null) {
            finish()
            return
        }

        // ✅ Get the active Flutter instance
        methodChannel = BrowserPlugin.methodChannel

        webView.settings.javaScriptEnabled = true
        webView.settings.domStorageEnabled = true  // Enable localStorage
        webView.settings.databaseEnabled = true   // Enable Web SQL database
        webView.settings.allowContentAccess = true
        webView.settings.allowFileAccess = true
        webView.webViewClient = object : WebViewClient() {

            // ✅ Notify Flutter on URL change
            override fun shouldOverrideUrlLoading(
                view: WebView?,
                request: WebResourceRequest?
            ): Boolean {
                val newUrl = request?.url.toString()
                methodChannel.invokeMethod("onUrlChanged", newUrl) // Send URL to Flutter

                if (isDeepLink(newUrl)) {
                    try {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(newUrl))
                        startActivity(intent)
                    } catch (e: ActivityNotFoundException) {
                        Toast.makeText(
                            this@WebViewActivity,
                            "No app found to open this link",
                            Toast.LENGTH_SHORT
                        ).show()
                    }
                    return true // Don't load in WebView, open in the app
                } else if (newUrl.contains(redirectUrl)) {
                    methodChannel.invokeMethod("onFinish", null) // Notify payment complete
                    finish()
                }

                return false // Allow WebView to load the URL
            }

            override fun onPageFinished(view: WebView?, url: String?) {

            }
        }

        webView.loadUrl(paymentUrl)
    }

    override fun onDestroy() {
        super.onDestroy()
        // WebView is being destroyed, can clean up resources here
        methodChannel.invokeMethod("onFinish", null) // Notify payment complete
        finish()
    }


    private fun isDeepLink(url: String): Boolean {
        val allowedSchemes =
            listOf("http", "https", "file", "chrome", "data", "javascript", "about")
        return allowedSchemes.none { url.startsWith("$it://") }
    }

}
