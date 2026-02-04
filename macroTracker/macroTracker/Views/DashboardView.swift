import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @State private var selectedDate = Date()
    @State private var isPresentingAdd = false
    @Query(sort: [SortDescriptor(\FoodEntry.timestamp, order: .forward)]) private var allEntries: [FoodEntry]

    private var repository: FoodRepository { FoodRepository(context: context) }

    var body: some View {
        NavigationStack {
            let interval = DateUtils.dayInterval(for: selectedDate)
            let entries = allEntries.filter { interval.contains($0.timestamp) }
            let totals = MacroCalculator.totals(for: entries)
            let targets = repository.targets().asValue
            ZStack {
                WackyBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        WackyCard {
                            DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .font(.wackyBody(16))
                        }

                        MacroProgressView(title: "Calories", consumed: totals.calories, target: targets.caloriesTarget, unit: "kcal", accent: WackyPalette.coolBlue)
                        MacroProgressView(title: "Protein", consumed: totals.protein, target: targets.proteinTarget, unit: "g", accent: WackyPalette.mutedGreen)
                        MacroProgressView(title: "Fat", consumed: totals.fat, target: targets.fatTarget, unit: "g", accent: WackyPalette.amber)
                        MacroProgressView(title: "Carbs", consumed: totals.carbs, target: targets.carbsTarget, unit: "g", accent: WackyPalette.slate)

                        Spacer(minLength: 0)
                    }
                    .padding()
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    isPresentingAdd = true
                } label: {
                    Label("Add Food", systemImage: "plus")
                }
            }
            .tint(WackyPalette.coolBlue)
            .sheet(isPresented: $isPresentingAdd) {
                FoodEntryFormView()
            }
        }
    }

    private func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }
}

#Preview {
    DashboardView()
}
