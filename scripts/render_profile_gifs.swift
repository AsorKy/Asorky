import AppKit
import ImageIO
import UniformTypeIdentifiers

let displayName = "Asorky"
let profession = "AI Engineer / Network Scientist"
let topics = [
    "Agentic Systems and RAG",
    "AI Automations",
    "Network Science",
    "Data Modeling and Analytics"
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
let source = NSImage(contentsOf: root.appendingPathComponent("assets/img2.jpg"))!
let headerFrames = (0..<12).map { frame -> CGImage in
    render(width: 1200, height: 450) {
        source.draw(in: NSRect(x: 0, y: 0, width: 1200, height: 450), from: .zero,
                    operation: .sourceOver, fraction: 1)
        let pulse = 0.92 + 0.08 * sin(Double(frame) * .pi / 6)
        let textShadow = NSShadow()
        textShadow.shadowColor = NSColor(calibratedWhite: 0, alpha: 0.9)
        textShadow.shadowBlurRadius = 5
        textShadow.shadowOffset = NSSize(width: 0, height: -2)
        let title = NSAttributedString(string: displayName, attributes: [
            .font: NSFont(name: "Avenir Next Demi Bold", size: 66)!,
            .foregroundColor: NSColor(calibratedWhite: 1, alpha: pulse),
            .shadow: textShadow
        ])
        let subtitle = NSAttributedString(string: profession, attributes: [
            .font: NSFont(name: "Avenir Next Medium", size: 30)!,
            .foregroundColor: NSColor.white,
            .shadow: textShadow
        ])
        let titleOrigin = NSPoint(x: (1200 - title.size().width) / 2, y: 235)
        let subtitleOrigin = NSPoint(x: (1200 - subtitle.size().width) / 2, y: 170)
        NSColor.black.setFill()
        NSBezierPath(rect: NSRect(x: 330, y: 142, width: 540, height: 188)).fill()
        title.draw(at: titleOrigin)
        subtitle.draw(at: subtitleOrigin)
        NSColor(calibratedRed: 0.14, green: 0.80, blue: 0.87, alpha: 0.64).setFill()
        NSBezierPath(roundedRect: NSRect(x: 515, y: 148, width: 170, height: 3), xRadius: 2, yRadius: 2).fill()
    }
}
writeGIF(headerFrames, to: root.appendingPathComponent("assets/asorky_header.gif").path, delay: 0.12)

let framesPerTopic = 40
let topicFont = NSFont(name: "Avenir Next Demi Bold", size: 36)!
let topicFrames = (0..<(topics.count * framesPerTopic)).map { frame -> CGImage in
    let topicIndex = frame / framesPerTopic
    let frameInTopic = frame % framesPerTopic
    let topic = topics[topicIndex]
    let typedText = String(topic.prefix(min(topic.count, frameInTopic)))
    let cursor = frameInTopic % 2 == 0 ? "▍" : " "
    let topicWidth = (topic as NSString).size(withAttributes: [.font: topicFont]).width
    let typingOriginX = ((CGFloat(1200) - topicWidth) / 2).rounded(.down)
    return render(width: 1200, height: 112) {
        NSColor(calibratedWhite: 0.025, alpha: 1).setFill()
        NSBezierPath(rect: NSRect(x: 0, y: 0, width: 1200, height: 112)).fill()
        let label = NSAttributedString(string: typedText + cursor, attributes: [
            .font: topicFont,
            .foregroundColor: NSColor.white
        ])
        label.draw(at: NSPoint(x: typingOriginX, y: 39))
    }
}
writeGIF(topicFrames, to: root.appendingPathComponent("assets/profile_topics.gif").path, delay: 0.08)
