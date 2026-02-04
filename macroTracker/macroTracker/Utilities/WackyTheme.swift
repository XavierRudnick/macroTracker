import SwiftUI

enum WackyPalette {
    static let ink = Color(red: 0.92, green: 0.93, blue: 0.95)
    static let cream = Color(red: 0.06, green: 0.07, blue: 0.08)
    static let slate = Color(red: 0.62, green: 0.67, blue: 0.74)
    static let graphite = Color(red: 0.18, green: 0.2, blue: 0.23)
    static let coolBlue = Color(red: 0.35, green: 0.55, blue: 0.78)
    static let mutedGreen = Color(red: 0.38, green: 0.72, blue: 0.6)
    static let amber = Color(red: 0.92, green: 0.62, blue: 0.25)
    static let warmSand = Color(red: 0.12, green: 0.13, blue: 0.15)

    static let card = Color(red: 0.1, green: 0.11, blue: 0.13)
    static let cardAlt = Color(red: 0.13, green: 0.15, blue: 0.18)
}

extension Font {
    static func wackyTitle(_ size: CGFloat) -> Font {
        .custom("HelveticaNeue-Medium", size: size)
    }

    static func wackyBody(_ size: CGFloat) -> Font {
        .custom("HelveticaNeue", size: size)
    }

    static func wackyCaps(_ size: CGFloat) -> Font {
        .custom("HelveticaNeue-Medium", size: size)
    }

    static func wackyMono(_ size: CGFloat) -> Font {
        .custom("Menlo-Regular", size: size)
    }
}

struct WackyBackground: View {
    var body: some View {
        LinearGradient(
            colors: [WackyPalette.cream, WackyPalette.graphite, WackyPalette.warmSand],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct WackyCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [WackyPalette.card, WackyPalette.cardAlt],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(WackyPalette.ink.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: WackyPalette.ink.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

struct WackyPill: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.wackyCaps(12))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(color.opacity(0.25))
            )
            .foregroundStyle(WackyPalette.ink)
    }
}

struct WackyProgressBar: View {
    let value: Double
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(WackyPalette.ink.opacity(0.08))
                Capsule(style: .continuous)
                    .fill(tint)
                    .frame(width: proxy.size.width * CGFloat(max(0, min(value, 1))))
            }
        }
        .frame(height: 10)
    }
}
