import SwiftUI

struct WeeklyView: View {
    @Environment(\.modelContext) private var context

    private var repository: FoodRepository { FoodRepository(context: context) }

    var body: some View {
        NavigationStack {
            let days = DateUtils.last7Days(endingOn: Date())
            let targets = repository.targets().asValue

            List(days, id: \.self) { day in
                let entries = repository.entries(on: day)
                let totals = MacroCalculator.totals(for: entries)
                WeeklyRowView(date: day, totals: totals, targets: targets)
            }
            .navigationTitle("Weekly")
        }
    }
}

struct WeeklyRowView: View {
    let date: Date
    let totals: MacroTotals
    let targets: MacroTargets

    private var adherence: Double {
        guard targets.caloriesTarget > 0 else { return 0 }
        return totals.calories / targets.caloriesTarget
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .font(.headline)
            HStack {
                Text("Calories: \(format(totals.calories))/\(format(targets.caloriesTarget))")
                Spacer()
                Text(adherenceLabel)
                    .font(.caption)
                    .foregroundStyle(adherenceColor)
            }
            ProgressView(value: min(max(adherence, 0), 1))
            Text("P \(format(totals.protein))  F \(format(totals.fat))  C \(format(totals.carbs))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var adherenceLabel: String {
        if adherence >= 0.9 && adherence <= 1.1 {
            return "On target"
        }
        if adherence < 0.9 {
            return "Below"
        }
        return "Above"
    }

    private var adherenceColor: Color {
        if adherence >= 0.9 && adherence <= 1.1 {
            return .green
        }
        if adherence < 0.9 {
            return .orange
        }
        return .red
    }

    private func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }
}
