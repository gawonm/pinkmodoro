import AppKit

/// Draws the menu bar icon as a Rose Quartz circle with a Serenity-colored
/// arc for the time remaining in the current session - the same two-tone
/// "shrinking time" idea as the page's own progress wedge/favicon. Used by
/// AppDelegate to set NSStatusItem.button.image directly (see
/// PinkmodoroWidgetApp.swift) rather than through a SwiftUI MenuBarExtra
/// label, which never reliably redrew for a changing image in this project.
enum PinkmodoroIcon {
    static let roseQuartz = NSColor(calibratedRed: 0xc0 / 255.0, green: 0x7b / 255.0, blue: 0x82 / 255.0, alpha: 1)
    static let serenity = NSColor(calibratedRed: 0x6e / 255.0, green: 0x8f / 255.0, blue: 0xbe / 255.0, alpha: 1)

    static func draw(ratio: Double, running: Bool) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)
        image.lockFocus()

        let rect = NSRect(x: 1, y: 1, width: size.width - 2, height: size.height - 2)
        let alpha: CGFloat = running ? 1.0 : 0.55

        roseQuartz.withAlphaComponent(alpha).setFill()
        NSBezierPath(ovalIn: rect).fill()

        let clamped = max(0, min(1, ratio))
        if clamped > 0.001 {
            let center = NSPoint(x: rect.midX, y: rect.midY)
            let radius = rect.width / 2
            let sweep = CGFloat(clamped * 360)
            let path = NSBezierPath()
            path.move(to: center)
            // 90 = top (12 o'clock); sweeping clockwise as time elapses mirrors
            // the page's own wedge, which shrinks the same way.
            path.appendArc(withCenter: center, radius: radius, startAngle: 90, endAngle: 90 - sweep, clockwise: true)
            path.close()
            serenity.withAlphaComponent(alpha).setFill()
            path.fill()
        }

        image.unlockFocus()
        image.isTemplate = false // keep the two colors instead of being masked to monochrome
        return image
    }
}
