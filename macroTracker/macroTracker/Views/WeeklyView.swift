import SwiftUI
import SwiftData

struct WeeklyView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\FoodEntry.timestamp, order: .forward)]) private var allEntries: [FoodEntry]

    private var repository: FoodRepository { FoodRepository(context: context) }

    var body: some View {
        NavigationStack {
            let days = DateUtils.last7Days(endingOn: Date())
            let targets = repository.targets().asValue

            ZStack {
                WackyBackground()
                List(days, id: \.self) { day in
                    let interval = DateUtils.dayInterval(for: day)
                    let entries = allEntries.filter { interval.contains($0.timestamp) }
                    let totals = MacroCalculator.totals(for: entries)
                    WeeklyRowView(date: day, totals: totals, targets: targets)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .navigationTitle("Weekly")
            .navigationBarTitleDisplayMode(.inline)
            .tint(WackyPalette.mutedGreen)
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
        WackyCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.wackyTitle(16))
                    .foregroundStyle(WackyPalette.ink)
                HStack {
                    Text("Calories: \(format(totals.calories))/\(format(targets.caloriesTarget))")
                        .font(.wackyMono(12))
                    Spacer()
                    WackyPill(text: adherenceLabel, color: adherenceColor)
                }
                WackyProgressBar(value: min(max(adherence, 0), 1), tint: adherenceColor)
                Text("P \(format(totals.protein))  F \(format(totals.fat))  C \(format(totals.carbs))")
                    .font(.wackyCaps(11))
                    .foregroundStyle(WackyPalette.ink.opacity(0.7))
            }
        }
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
            return WackyPalette.mutedGreen
        }
        if adherence < 0.9 {
            return WackyPalette.coolBlue
        }
        return WackyPalette.graphite
    }

    private func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }
}
