import Foundation
import Combine
import WebKit
import UserNotifications

/// Receives postMessage calls from the web app's JS (window.webkit.messageHandlers.pinkmodoroNative)
/// and shows a native macOS notification banner via UNUserNotificationCenter, since WKWebView's
/// support for the web Notification API is unreliable across macOS versions.
final class TimerBridge: NSObject, ObservableObject, WKScriptMessageHandler {
    /// Mirrors the web page's document.title (e.g. "24:59 · 집중" or "핑크모도로" when idle),
    /// shown as the menu bar label next to the timer icon.
    @Published var menuBarLabel: String = "핑크모도로"
    /// Fraction of the current session remaining (1 = just started, 0 = done),
    /// mirrored from the page's own postMessage({type:"tray", ratio, running})
    /// so the menu bar icon can draw the same shrinking-time arc as the page's
    /// own favicon, instead of a static image.
    @Published var ratio: Double = 0
    @Published var running: Bool = false

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "pinkmodoroNative",
              let body = message.body as? [String: Any],
              let type = body["type"] as? String else { return }

        switch type {
        case "notify":
            let title = body["title"] as? String ?? "핑크모도로"
            let text = body["body"] as? String ?? ""

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = text
            content.sound = .default

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request)

        case "tray":
            ratio = (body["ratio"] as? Double) ?? 0
            running = (body["running"] as? Bool) ?? false

        default:
            break
        }
    }
}

/// WKUserContentController retains its message handlers strongly; wrapping the real handler in a
/// weak proxy avoids a retain cycle between the controller and the long-lived TimerBridge.
final class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    private weak var delegate: WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}
