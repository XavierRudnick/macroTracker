import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @State private var selectedDate = Date()
    @State private var isPresentingAdd = false

    private var repository: FoodRepository { FoodRepository(context: context) }

    var body: some View {
        NavigationStack {
            let entries = repository.entries(on: selectedDate)
            let totals = MacroCalculator.totals(for: entries)
            let targets = repository.targets().asValue
            let remaining = MacroCalculator.remaining(for: totals, targets: targets)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)

                    MacroProgressView(title: "Calories", consumed: totals.calories, target: targets.caloriesTarget, unit: "kcal")
                    MacroProgressView(title: "Protein", consumed: totals.protein, target: targets.proteinTarget, unit: "g")
                    MacroProgressView(title: "Fat", consumed: totals.fat, target: targets.fatTarget, unit: "g")
                    MacroProgressView(title: "Carbs", consumed: totals.carbs, target: targets.carbsTarget, unit: "g")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Remaining Summary")
                            .font(.headline)
                        HStack {
                            Text("Calories")
                            Spacer()
                            Text("\(format(remaining.calories)) kcal")
                                .foregroundStyle(remaining.calories < 0 ? .red : .primary)
                        }
                        HStack {
                            Text("Protein")
                            Spacer()
                            Text("\(format(remaining.protein)) g")
                                .foregroundStyle(remaining.protein < 0 ? .red : .primary)
                        }
                        HStack {
                            Text("Fat")
                            Spacer()
                            Text("\(format(remaining.fat)) g")
                                .foregroundStyle(remaining.fat < 0 ? .red : .primary)
                        }
                        HStack {
                            Text("Carbs")
                            Spacer()
                            Text("\(format(remaining.carbs)) g")
                                .foregroundStyle(remaining.carbs < 0 ? .red : .primary)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                Button {
                    isPresentingAdd = true
                } label: {
                    Label("Add Food", systemImage: "plus")
                }
            }
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
