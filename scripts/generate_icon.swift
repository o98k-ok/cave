import AppKit
import Foundation

func drawIcon(size: Int, output: URL) {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else { return }

    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    let colors = [
        NSColor(calibratedRed: 0.06, green: 0.09, blue: 0.18, alpha: 1).cgColor,
        NSColor(calibratedRed: 0.11, green: 0.18, blue: 0.30, alpha: 1).cgColor,
        NSColor(calibratedRed: 0.03, green: 0.05, blue: 0.10, alpha: 1).cgColor
    ] as CFArray
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.6, 1])!
    ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: CGFloat(size)), end: CGPoint(x: CGFloat(size), y: 0), options: [])

    let c = CGPoint(x: CGFloat(size) * 0.5, y: CGFloat(size) * 0.52)
    let haloR = CGFloat(size) * 0.37
    let ringRect = CGRect(x: c.x - haloR, y: c.y - haloR * 0.58, width: haloR * 2, height: haloR * 1.16)

    ctx.setStrokeColor(NSColor(calibratedRed: 0.40, green: 0.75, blue: 1.0, alpha: 0.7).cgColor)
    ctx.setLineWidth(max(1.5, CGFloat(size) * 0.02))
    ctx.addEllipse(in: ringRect)
    ctx.strokePath()

    let innerRect = CGRect(x: c.x - CGFloat(size) * 0.17, y: c.y - CGFloat(size) * 0.17, width: CGFloat(size) * 0.34, height: CGFloat(size) * 0.34)
    ctx.setFillColor(NSColor.black.cgColor)
    ctx.addEllipse(in: innerRect)
    ctx.fillPath()

    ctx.setStrokeColor(NSColor(calibratedWhite: 1, alpha: 0.15).cgColor)
    ctx.setLineWidth(max(1.0, CGFloat(size) * 0.01))
    let borderRect = rect.insetBy(dx: CGFloat(size) * 0.03, dy: CGFloat(size) * 0.03)
    let borderPath = CGPath(roundedRect: borderRect, cornerWidth: CGFloat(size) * 0.22, cornerHeight: CGFloat(size) * 0.22, transform: nil)
    ctx.addPath(borderPath)
    ctx.strokePath()

    image.unlockFocus()

    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let data = rep.representation(using: .png, properties: [:]) else { return }
    try? data.write(to: output)
}

func main() {
    let base = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let iconset = base.appendingPathComponent("Resources/cave.iconset", isDirectory: true)
    try? FileManager.default.removeItem(at: iconset)
    try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

    let files: [(Int, String)] = [
        (16, "icon_16x16.png"),
        (32, "icon_16x16@2x.png"),
        (32, "icon_32x32.png"),
        (64, "icon_32x32@2x.png"),
        (128, "icon_128x128.png"),
        (256, "icon_128x128@2x.png"),
        (256, "icon_256x256.png"),
        (512, "icon_256x256@2x.png"),
        (512, "icon_512x512.png"),
        (1024, "icon_512x512@2x.png")
    ]

    for (size, name) in files {
        drawIcon(size: size, output: iconset.appendingPathComponent(name))
    }
}

main()
