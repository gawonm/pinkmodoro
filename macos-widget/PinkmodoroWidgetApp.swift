import SwiftUI
import UserNotifications

@main
struct PinkmodoroWidgetApp: App {
    @StateObject private var bridge = TimerBridge()

    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    var body: some Scene {
        MenuBarExtra(bridge.menuBarLabel, systemImage: "timer") {
            PinkmodoroPopoverView()
                .environmentObject(bridge)
        }
        .menuBarExtraStyle(.window)
    }
}
