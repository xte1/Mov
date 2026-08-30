import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @Binding var urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // تفعيل خاصية الـ PiP إن وجدت
        if #available(iOS 14.0, *) {
            configuration.allowsPictureInPictureMediaPlayback = true
        }
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .black
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: urlString), uiView.url?.absoluteString != urlString else { return }
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
