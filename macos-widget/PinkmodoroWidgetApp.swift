import SwiftUI
import UserNotifications

@main
struct PinkmodoroWidgetApp: App {
    @StateObject private var bridge = TimerBridge()

    init() {
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
