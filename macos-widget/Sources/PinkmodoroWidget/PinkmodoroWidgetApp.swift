import SwiftUI
import AppKit
import Combine
import UserNotifications

/// Owns the actual menu bar UI with plain AppKit (NSStatusItem + NSPopover)
/// instead of SwiftUI's `MenuBarExtra`. MenuBarExtra turned out unreliable for
/// everything beyond a static label in this project: a custom asset-catalog
/// icon never rendered, `.onHover` never fired, and even a live-updating
/// SwiftUI label view (bound to @Published state) didn't visibly redraw when
/// only the icon's drawn content changed. Setting `statusItem.button.image`
/// directly whenever the bridge's state changes is the standard, reliable
/// AppKit way to do this.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private let bridge = TimerBridge()
    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hides the Dock icon so this behaves as a menu-bar-only app even when
        // run straight from `swift run` / an ad-hoc .app bundle that has no
        // Xcode-set "Application is agent (UIElement)" Info.plist key.
        NSApplication.shared.setActivationPolicy(.accessory)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.action = #selector(togglePopover(_:))
        statusItem.button?.target = self

        popover = NSPopover()
        popover.behavior = .transient
        // Matches PinkmodoroPopoverView's own fixed-size VStack (380x620
        // WebView + divider + padded button row) - set explicitly rather
        // than via fittingSize, which can read as zero before the hosting
        // controller's view has ever been laid out.
        popover.contentSize = NSSize(width: 380, height: 660)
        popover.contentViewController = NSHostingController(
            rootView: PinkmodoroPopoverView().environmentObject(bridge)
        )

        refreshStatusItem()

        // objectWillChange fires in @Published's willSet, i.e. before the new
        // value is actually stored - dispatch to the next runloop turn so
        // refreshStatusItem reads the values *after* they've been updated.
        bridge.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async { self?.refreshStatusItem() }
            }
            .store(in: &cancellables)
    }

    private func refreshStatusItem() {
        guard let button = statusItem.button else { return }
        button.image = PinkmodoroIcon.draw(ratio: bridge.ratio, running: bridge.running)
        button.imagePosition = .imageLeading
        button.title = " " + bridge.menuBarLabel
        button.font = .systemFont(ofSize: 13)
    }

    @objc private func togglePopover(_ sender: AnyObject) {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}

@main
struct PinkmodoroWidgetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // All real UI is owned by AppDelegate (NSStatusItem + NSPopover); this
        // scene exists only because a SwiftUI App needs at least one.
        Settings {
            EmptyView()
        }
    }
}
