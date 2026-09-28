import SwiftUI

/// The menu bar's status item content: a fixed SF Symbol at rest, with the
/// live countdown text sliding in only while the pointer is hovering over it.
///
/// A custom named-asset icon (the tomato artwork) reliably failed to render
/// here even though it compiled into the bundle correctly and showed fine in
/// Xcode's own asset catalog preview - swapping to an SF Symbol fixed it
/// immediately, so the symbol is kept as the reliable choice.
struct MenuBarLabelView: View {
    @ObservedObject var bridge: TimerBridge
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "timer")

            if isHovering {
                Text(bridge.menuBarLabel)
                    .font(.system(size: 13))
                    .lineLimit(1)
                    .fixedSize()
            }
        }
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
