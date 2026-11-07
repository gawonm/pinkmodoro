import SwiftUI
import AppKit
import UserNotifications

/// `NSApp` isn't guaranteed to be set up yet inside `App.init()` - that's too
/// early, especially when launched as a bare `swift run` executable instead
/// of a proper .app bundle, and force-unwrapping it there can crash with
/// "Unexpectedly found nil". `applicationDidFinishLaunching` is the documented
/// safe point to touch NSApplication.
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hides the Dock icon so this behaves as a menu-bar-only app even when
        // run straight from `swift run` / an ad-hoc .app bundle that has no
        // Xcode-set "Application is agent (UIElement)" Info.plist key.
        NSApplication.shared.setActivationPolicy(.accessory)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
}

@main
struct PinkmodoroWidgetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var bridge = TimerBridge()

    var body: some Scene {
        MenuBarExtra {
            PinkmodoroPopoverView()
                .environmentObject(bridge)
        } label: {
            MenuBarLabelView(bridge: bridge)
        }
        .menuBarExtraStyle(.window)
    }
}
