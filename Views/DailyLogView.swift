import SwiftUI

struct DailyLogView: View {
    @Environment(\.modelContext) private var context
    @State private var selectedDate = Date()
    @State private var selectedEntry: FoodEntry?
    @State private var isPresentingAdd = false

    private var repository: FoodRepository { FoodRepository(context: context) }

    var body: some View {
        NavigationStack {
            let entries = repository.entries(on: selectedDate)

            List {
                Section {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                }

                ForEach(MealType.allCases) { mealType in
                    let items = entries.filter { $0.mealType == mealType }
                    if !items.isEmpty {
                        Section(mealType.rawValue) {
                            ForEach(items) { entry in
                                Button {
                                    selectedEntry = entry
                                } label: {
                                    EntryRowView(entry: entry)
                                }
                                .buttonStyle(.plain)
                            }
                            .onDelete { indexSet in
                                delete(items: items, offsets: indexSet)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Daily Log")
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
            .sheet(item: $selectedEntry) { entry in
                FoodEntryFormView(entry: entry)
            }
        }
    }

    private func delete(items: [FoodEntry], offsets: IndexSet) {
        for index in offsets {
            let entry = items[index]
            do {
                try repository.deleteEntry(entry)
            } catch {
                return
            }
        }
    }
}

struct EntryRowView: View {
    let entry: FoodEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.name)
                    .font(.headline)
                if let serving = entry.serving, !serving.isEmpty {
                    Text(serving)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(format(entry.calories)) kcal")
                    .font(.subheadline)
                Text("P \(format(entry.protein))  F \(format(entry.fat))  C \(format(entry.carbs))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }
}
