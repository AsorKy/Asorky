import AppKit
import ImageIO
import UniformTypeIdentifiers

let displayName = "Asorky"
let profession = "AI Engineer / Network Scientist"
let topics = [
    "AGENTIC SYSTEMS & RAG",
    "AI AUTOMATIONS",
    "NETWORK SCIENCE",
    "DATA MODELING & ANALYTICS"
]

func render(width: Int, height: Int, drawContent: () -> Void) -> CGImage {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height,
                                  bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                                  isPlanar: false, colorSpaceName: .deviceRGB,
                                  bytesPerRow: 0, bitsPerPixel: 0)!
    let context = NSGraphicsContext(bitmapImageRep: bitmap)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    drawContent()
    context.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()
    return bitmap.cgImage!
}

func writeGIF(_ images: [CGImage], to path: String, delay: Double) {
    let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL,
                                                      UTType.gif.identifier as CFString,
                                                      images.count, nil)!
    CGImageDestinationSetProperties(destination,
        [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]] as CFDictionary)
    for image in images {
        CGImageDestinationAddImage(destination, image,
            [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: delay]] as CFDictionary)
    }
    precondition(CGImageDestinationFinalize(destination))
}

let root = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent().deletingLastPathComponent()
let source = NSImage(contentsOf: root.appendingPathComponent("assets/img3.jpg"))!
let headerFrames = (0..<12).map { frame -> CGImage in
    render(width: 1200, height: 300) {
        source.draw(in: NSRect(x: 0, y: 0, width: 1200, height: 300), from: .zero,
                    operation: .sourceOver, fraction: 1)
        NSColor(calibratedWhite: 0.02, alpha: 0.47).setFill()
        NSBezierPath(rect: NSRect(x: 0, y: 0, width: 1200, height: 300)).fill()
        let pulse = 0.92 + 0.08 * sin(Double(frame) * .pi / 6)
        let title = NSAttributedString(string: displayName, attributes: [
            .font: NSFont(name: "Avenir Next Demi Bold", size: 66)!,
            .foregroundColor: NSColor(calibratedRed: 0.43, green: 0.91, blue: 0.97, alpha: pulse)
        ])
        let subtitle = NSAttributedString(string: profession, attributes: [
            .font: NSFont(name: "Avenir Next Medium", size: 26)!,
            .foregroundColor: NSColor.white
        ])
        title.draw(at: NSPoint(x: (1200 - title.size().width) / 2, y: 150))
        subtitle.draw(at: NSPoint(x: (1200 - subtitle.size().width) / 2, y: 102))
        NSColor(calibratedRed: 0.14, green: 0.80, blue: 0.87, alpha: 0.8).setFill()
        NSBezierPath(roundedRect: NSRect(x: 515, y: 82, width: 170, height: 3), xRadius: 2, yRadius: 2).fill()
    }
}
writeGIF(headerFrames, to: root.appendingPathComponent("assets/asorky_header.gif").path, delay: 0.12)

let topicFrames = (0..<24).map { frame -> CGImage in
    render(width: 900, height: 92) {
        NSColor(calibratedRed: 0.025, green: 0.10, blue: 0.15, alpha: 1).setFill()
        NSBezierPath(rect: NSRect(x: 0, y: 0, width: 900, height: 92)).fill()
        NSColor(calibratedRed: 0.08, green: 0.31, blue: 0.37, alpha: 1).setStroke()
        let border = NSBezierPath(roundedRect: NSRect(x: 1, y: 1, width: 898, height: 90), xRadius: 14, yRadius: 14)
        border.lineWidth = 2
        border.stroke()
        for index in 0..<4 {
            let active = index == (frame / 6) % 4
            let label = NSAttributedString(string: topics[index], attributes: [
                .font: NSFont(name: active ? "Avenir Next Demi Bold" : "Avenir Next Medium", size: active ? 16 : 14)!,
                .foregroundColor: active
                    ? NSColor(calibratedRed: 0.45, green: 0.91, blue: 0.96, alpha: 1)
                    : NSColor(calibratedWhite: 0.88, alpha: 0.8)
            ])
            let cellWidth = 225.0
            label.draw(at: NSPoint(x: Double(index) * cellWidth + (cellWidth - label.size().width) / 2, y: 39))
            if index < 3 {
                NSColor(calibratedRed: 0.14, green: 0.80, blue: 0.87, alpha: 0.55).setFill()
                NSBezierPath(ovalIn: NSRect(x: Double(index + 1) * cellWidth - 2, y: 43, width: 4, height: 4)).fill()
            }
        }
        let activeIndex = (frame / 6) % 4
        NSColor(calibratedRed: 0.14, green: 0.80, blue: 0.87, alpha: 0.9).setFill()
        NSBezierPath(roundedRect: NSRect(x: Double(activeIndex) * 225 + 80, y: 20,
                                         width: 65, height: 2), xRadius: 1, yRadius: 1).fill()
    }
}
writeGIF(topicFrames, to: root.appendingPathComponent("assets/profile_topics.gif").path, delay: 0.16)
