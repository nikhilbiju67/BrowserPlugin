import UIKit
import WebKit
import Flutter

/// A ViewController that presents a WebView for handling online .
class WebViewController: UIViewController, WKNavigationDelegate {

    // MARK: - Properties

    /// URL to load the page
    var url: String = ""

    var redirectUrl: String = ""
    private var closeButton = UIButton(type: .system)

    /// Constraint for positioning the close button dynamically.
    private var closeButtonTopConstraint: NSLayoutConstraint?

    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()

        // ✅ Enable JavaScript for better interactivity.
        webConfiguration.preferences.javaScriptEnabled = true

        // ✅ Enable local storage for session-based transactions.
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
           webView.isUserInteractionEnabled = true  // ✅ Ensure interaction is enabled
           webView.allowsLinkPreview = false        // ✅ Prevent link previews that may interfere with the experience

           // ✅ Remove scrollbars
           webView.scrollView.showsHorizontalScrollIndicator = false
           webView.scrollView.showsVerticalScrollIndicator = false    // ✅ Prevent link previews that may interfere with the experience
        return webView
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPage()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // ✅ Ensure the close button is correctly positioned below the status bar.
        let safeAreaTop = view.safeAreaInsets.top
        closeButtonTopConstraint?.constant = safeAreaTop + 10
    }

    // MARK: - UI Setup

    /// Sets up the UI components: top bar, close button, and WebView.
    private func setupUI() {
        // ✅ Add WebView to the view hierarchy
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        // ✅ Close button to dismiss the WebView
        closeButton = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            closeButton.setImage(UIImage(systemName: "xmark"), for: .normal) // System close icon
        } else {
            closeButton.setTitle("X", for: .normal) // Fallback text for older iOS versions
        }

        // ✅ Configure close button appearance
        updateCloseButtonAppearance()

        closeButton.addTarget(self, action: #selector(closeWebView), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        // ✅ Apply Auto Layout constraints
        NSLayoutConstraint.activate([
            // ✅ WebView constraints (fills entire view)
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // ✅ Close button constraints (smaller size, right-aligned)
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16), // Right side padding
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -14), // Move slightly up
            closeButton.widthAnchor.constraint(equalToConstant: 28), // Smaller size
            closeButton.heightAnchor.constraint(equalToConstant: 28) // Smaller size
        ])
    }

    // ✅ Update button appearance dynamically
    private func updateCloseButtonAppearance() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        closeButton.tintColor = isDarkMode ? .white : .black
        closeButton.backgroundColor = isDarkMode ? .black : .white
        closeButton.layer.cornerRadius = 14 // Adjusted for smaller size
        closeButton.layer.masksToBounds = true
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
           closeButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)

        // ✅ Add a slight shadow for better visibility
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOpacity = 0.3
        closeButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        closeButton.layer.shadowRadius = 3
    }



    // MARK: - WebView Handling

    /// Loads the URL inside the WebView.
    private func loadPage() {
        guard let url = URL(string: url) else {
            print("❌ Invalid  URL: \(url)")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    /// Handles URL navigation and interactions inside the WebView.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let url = navigationAction.request.url?.absoluteString else {
            decisionHandler(.allow)
            return
        }

        print("🔄 Navigated to: \(url)")

        // ✅ Notify Flutter about URL changes
        BrowserPlugin.methodChannel?.invokeMethod("onUrlChanged", arguments: url)

        // ✅ Check if url is completed and redirect accordingly
        if url.contains(redirectUrl) {
    
            BrowserPlugin.methodChannel?.invokeMethod("onFinish", arguments: nil)
            dismiss(animated: true, completion: nil)
            decisionHandler(.cancel) // Prevent WebView from further loading
            return
        }

        // ✅ Handle deep links (redirecting outside the WebView)
        if isDeepLink(url) {
            if let deepLinkUrl = URL(string: url) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(deepLinkUrl, options: [:]) { success in
                        if !success {
                            print("❌ No app found to open this deep link")
                        }
                    }
                }
            }
            decisionHandler(.cancel) // Prevent WebView from loading deep links
            return
        }

        decisionHandler(.allow) // Allow WebView to continue loading normally
    }

    // MARK: - Helper Methods

    /// Checks if a given URL is a deep link (i.e., should open an external app instead of WebView).
    private func isDeepLink(_ url: String) -> Bool {
        let allowedSchemes = ["http", "https", "file", "chrome", "data", "javascript", "about"]
        return !allowedSchemes.contains { url.hasPrefix("\($0)://") }
    }

    // MARK: - Close WebView

    /// Closes the WebView and notifies Flutter that the webview  is completed.
    @objc private func closeWebView() {
        BrowserPlugin.methodChannel?.invokeMethod("onFinish", arguments: nil)
        dismiss(animated: true, completion: nil)
    }
}

