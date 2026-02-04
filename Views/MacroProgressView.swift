import SwiftUI

struct MacroProgressView: View {
    let title: String
    let consumed: Double
    let target: Double
    let unit: String

    private var remaining: Double { target - consumed }
    private var progress: Double { target == 0 ? 0 : consumed / target }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(format(consumed))/\(format(target)) \(unit)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: min(max(progress, 0), 1))
            HStack {
                Text("Remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(format(remaining)) \(unit)")
                    .font(.caption)
                    .foregroundStyle(remaining < 0 ? .red : .primary)
            }
        }
        .padding(.vertical, 4)
    }

    private func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }
}
