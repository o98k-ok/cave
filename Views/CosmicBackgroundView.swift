import SwiftUI

struct CosmicBackgroundView: View {
    private var selectedTheme: AppTheme {
        AppTheme.from(code: UserDefaults.standard.string(forKey: AppTheme.storageKey) ?? AppTheme.defaultTheme.rawValue)
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 30.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate

            Canvas { context, size in
                let rect = CGRect(origin: .zero, size: size)
                if selectedTheme == .light {
                    context.fill(
                        Path(rect),
                        with: .linearGradient(
                            Gradient(colors: [
                                Color(red: 0.92, green: 0.96, blue: 1.0),
                                Color(red: 0.86, green: 0.93, blue: 0.99),
                                Color(red: 0.80, green: 0.90, blue: 0.98)
                            ]),
                            startPoint: CGPoint(x: 0, y: 0),
                            endPoint: CGPoint(x: size.width, y: size.height)
                        )
                    )
                } else {
                    context.fill(Path(rect), with: .color(Color.black))
                }

                let center = CGPoint(x: size.width * 0.5, y: size.height * 0.48)
                let wave = CGFloat(sin(t * 0.8) * 22.0)

                let halo = CGRect(
                    x: center.x - 210 - wave * 0.8,
                    y: center.y - 210 - wave * 0.8,
                    width: 420 + wave * 1.6,
                    height: 420 + wave * 1.6
                )
                context.fill(
                    Path(ellipseIn: halo),
                    with: .radialGradient(
                        Gradient(colors: [
                            selectedTheme == .light
                                ? Color(red: 0.58, green: 0.78, blue: 0.95).opacity(0.34)
                                : Color(red: 0.02, green: 0.07, blue: 0.13).opacity(0.80),
                            selectedTheme == .light
                                ? Color(red: 0.44, green: 0.70, blue: 0.92).opacity(0.22)
                                : Color(red: 0.03, green: 0.12, blue: 0.18).opacity(0.42),
                            (selectedTheme == .light ? Color.white : Color.black).opacity(0.0)
                        ]),
                        center: center,
                        startRadius: 20,
                        endRadius: 220
                    )
                )

                let ring = CGRect(
                    x: center.x - 130 + sin(t * 1.6) * 8,
                    y: center.y - 72 + cos(t * 1.2) * 6,
                    width: 260,
                    height: 144
                )
                context.fill(
                    Path(ellipseIn: ring),
                    with: .radialGradient(
                        Gradient(colors: [
                            Color(red: 0.20, green: 0.58, blue: 0.96).opacity(0.0),
                            Color(red: 0.30, green: 0.74, blue: 1.0).opacity(selectedTheme == .light ? 0.14 : 0.30),
                            Color(red: 0.53, green: 0.86, blue: 1.0).opacity(0.0)
                        ]),
                        center: CGPoint(x: ring.midX, y: ring.midY),
                        startRadius: 16,
                        endRadius: 132
                    )
                )

                if selectedTheme != .light {
                    let hole = CGRect(x: center.x - 58, y: center.y - 58, width: 116, height: 116)
                    context.fill(
                        Path(ellipseIn: hole),
                        with: .radialGradient(
                            Gradient(colors: [Color.black, Color.black.opacity(0.92), Color.black.opacity(0.35)]),
                            center: center,
                            startRadius: 4,
                            endRadius: 58
                        )
                    )
                }

                for i in 0..<70 {
                    let fi = Double(i)
                    let px = (sin(fi * 78.233) * 43758.5453).truncatingRemainder(dividingBy: 1)
                    let py = (sin(fi * 31.947) * 19642.3491).truncatingRemainder(dividingBy: 1)
                    let drift = sin(t * 0.18 + fi) * 4.0
                    let x = (abs(px) * size.width + drift).truncatingRemainder(dividingBy: size.width)
                    let y = (abs(py) * size.height + cos(t * 0.14 + fi) * 2.0).truncatingRemainder(dividingBy: size.height)

                    let twinkle = 0.35 + 0.65 * abs(sin(t * (0.55 + fi * 0.01) + fi))
                    let r = 0.5 + CGFloat((fi.truncatingRemainder(dividingBy: 3)) * 0.35)
                    let starRect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                    let starColor = selectedTheme == .light ? Color.white.opacity(twinkle * 0.45) : Color.white.opacity(twinkle * 0.7)
                    context.fill(Path(ellipseIn: starRect), with: .color(starColor))
                }
            }
        }
        .overlay(
            LinearGradient(
                colors: [
                    selectedTheme == .light ? Color.white.opacity(0.12) : Color.black.opacity(0.12),
                    selectedTheme == .light ? Color.white.opacity(0.16) : Color.black.opacity(0.45),
                    selectedTheme == .light ? Color.white.opacity(0.22) : Color.black.opacity(0.78)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea()
    }
}
