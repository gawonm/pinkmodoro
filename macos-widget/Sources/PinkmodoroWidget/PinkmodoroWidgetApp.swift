import SwiftUI
import AppKit
import UserNotifications

@main
struct PinkmodoroWidgetApp: App {
    @StateObject private var bridge = TimerBridge()

    init() {
        // Hides the Dock icon so this behaves as a menu-bar-only app even when
        // run straight from `swift run` / an ad-hoc .app bundle that has no
        // Xcode-set "Application is agent (UIElement)" Info.plist key.
        NSApp.setActivationPolicy(.accessory)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

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
