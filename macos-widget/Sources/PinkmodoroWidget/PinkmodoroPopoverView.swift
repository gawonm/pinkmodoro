import SwiftUI
import AppKit

struct PinkmodoroPopoverView: View {
    @EnvironmentObject var bridge: TimerBridge

    // Point this at your own GitHub Pages URL if you fork the repo under a different owner.
    private let siteURL = URL(string: "https://gawonm.github.io/pinkmodoro/")!

    var body: some View {
        VStack(spacing: 0) {
            PinkmodoroWebView(bridge: bridge, url: siteURL)
                .frame(width: 380, height: 620)

            Divider()

            HStack {
                Button("브라우저에서 열기") {
                    NSWorkspace.shared.open(siteURL)
                }
                Spacer()
                Button("종료") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(8)
        }
    }
}
