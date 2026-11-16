// Dibuja el icono de la app (taza de café sobre cristal negro ceniza).
// Uso: swift icon.swift AppIcon.iconset && iconutil -c icns AppIcon.iconset

import AppKit

let folder = URL(fileURLWithPath: CommandLine.arguments[1])
try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

func color(_ hex: UInt32) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
}

func drawIcon(pixels: Int) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let s = CGFloat(pixels)
    let inset = s * 0.1  // margen estándar de los iconos de macOS
    let rect = NSRect(x: inset, y: inset * 1.15, width: s - inset * 2, height: s - inset * 2)
    let shape = NSBezierPath(roundedRect: rect, xRadius: rect.width * 0.225, yRadius: rect.width * 0.225)

    // Sombra suave
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
    shadow.shadowBlurRadius = s * 0.03
    shadow.shadowOffset = NSSize(width: 0, height: -s * 0.012)
    shadow.set()
    color(0x1C1B1A).setFill()
    shape.fill()
    NSGraphicsContext.restoreGraphicsState()

    // Degradado ceniza
    NSGradient(colors: [color(0x5A5753), color(0x2A2927), color(0x141413)])!.draw(in: shape, angle: -65)

    // Brillo arriba
    NSGraphicsContext.saveGraphicsState()
    shape.addClip()
    NSGradient(colors: [NSColor.white.withAlphaComponent(0.16), NSColor.white.withAlphaComponent(0)])!
        .draw(in: NSRect(x: rect.minX, y: rect.midY, width: rect.width, height: rect.height / 2), angle: -90)
    NSGraphicsContext.restoreGraphicsState()

    // Taza
    let config = NSImage.SymbolConfiguration(pointSize: s * 0.36, weight: .semibold)
        .applying(NSImage.SymbolConfiguration(paletteColors: [color(0xECEAE6)]))
    if let cup = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: nil)?
        .withSymbolConfiguration(config) {
        let size = cup.size
        cup.draw(in: NSRect(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2 - s * 0.01,
                            width: size.width, height: size.height))
    }

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

for base in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let name = "icon_\(base)x\(base)\(scale == 2 ? "@2x" : "").png"
        try drawIcon(pixels: base * scale).write(to: folder.appendingPathComponent(name))
    }
}
print("🎨 Icono dibujado en \(folder.path)")
