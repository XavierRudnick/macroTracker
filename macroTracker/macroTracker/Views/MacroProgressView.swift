import SwiftUI

struct MacroProgressView: View {
    let title: String
    let consumed: Double
    let target: Double
    let unit: String
    let accent: Color

    private var remaining: Double { target - consumed }
    private var progress: Double { target == 0 ? 0 : consumed / target }
    private var isMet: Bool { consumed >= target && target > 0 }

    var body: some View {
        WackyCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.wackyTitle(17))
                        .foregroundStyle(WackyPalette.ink)
                    Spacer()
                    Text("\(format(consumed))/\(format(target)) \(unit)")
                        .font(.wackyMono(13))
                        .foregroundStyle(WackyPalette.ink.opacity(0.75))
                }
                WackyProgressBar(value: progress, tint: accent)
                HStack {
                    if isMet {
                        Label("Goal met", systemImage: "checkmark.seal.fill")
                            .font(.wackyCaps(12))
                            .foregroundStyle(WackyPalette.mutedGreen)
                    } else {
                        WackyPill(text: "Remaining", color: accent)
                    }
                    Spacer()
                    Text("\(format(max(remaining, 0))) \(unit)")
                        .font(.wackyMono(13))
                        .foregroundStyle(isMet ? WackyPalette.mutedGreen : WackyPalette.ink)
                }
            }
        }
    }

    private func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }
}
