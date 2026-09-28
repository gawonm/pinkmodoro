import SwiftUI
import WebKit

/// Wraps a WKWebView pointed at the live pinkmodoro site and installs the
/// "pinkmodoroNative" message handler the web app looks for.
struct PinkmodoroWebView: NSViewRepresentable {
    @ObservedObject var bridge: TimerBridge
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(bridge: bridge)
    }

    func makeNSView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()
        contentController.add(WeakScriptMessageHandler(delegate: bridge), name: "pinkmodoroNative")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.load(URLRequest(url: url))
        context.coordinator.observe(webView)
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}

    final class Coordinator: NSObject {
        private let bridge: TimerBridge
        private var titleObservation: NSKeyValueObservation?

        init(bridge: TimerBridge) {
            self.bridge = bridge
        }

        func observe(_ webView: WKWebView) {
            titleObservation = webView.observe(\.title, options: [.new]) { [weak self] _, change in
                guard let title = change.newValue as? String, !title.isEmpty else { return }
                DispatchQueue.main.async {
                    self?.bridge.menuBarLabel = title
                }
            }
        }
    }
}
