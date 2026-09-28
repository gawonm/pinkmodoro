import SwiftUI

/// The menu bar's status item content: the tomato icon at rest, with the
/// live countdown text sliding in only while the pointer is hovering over it.
struct MenuBarLabelView: View {
    @ObservedObject var bridge: TimerBridge
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 4) {
            Image("MenuBarIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)

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
