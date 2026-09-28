import SwiftUI

/// The menu bar's status item content: SF Symbol icon plus the live
/// countdown text, always shown together (hover-to-reveal was tried but
/// SwiftUI's .onHover isn't reliably delivered on NSStatusItem-hosted
/// content, so this always-visible form is the dependable choice).
struct MenuBarLabelView: View {
    @ObservedObject var bridge: TimerBridge

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "timer")
            Text(bridge.menuBarLabel)
                .font(.system(size: 13))
                .lineLimit(1)
                .fixedSize()
        }
    }
}
