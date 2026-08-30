import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @Binding var urlString: String
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true

    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        configuration.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        // تعيين User-Agent قياسي لمنع حظر المواقع
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1"
        
        loadURL(in: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // تحديث المظهر الداكن للمتصفح
        uiView.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        
        // إعادة التحميل في حال تغير الرابط
        if let currentURL = uiView.url?.absoluteString, currentURL != urlString {
            loadURL(in: uiView)
        }
    }

    private func loadURL(in webView: WKWebView) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("Failed to load: \(error.localizedDescription)")
        }
    }
}
