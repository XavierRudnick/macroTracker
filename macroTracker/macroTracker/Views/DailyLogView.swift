import SwiftUI
import SwiftData

struct DailyLogView: View {
    @Environment(\.modelContext) private var context
    @State private var selectedDate = Date()
    @State private var selectedEntry: FoodEntry?
    @State private var isPresentingAdd = false
    @State private var isPresentingMealPicker = false
    @State private var selectedTemplate: MealTemplate?
    @Query(sort: [SortDescriptor(\FoodEntry.timestamp, order: .forward)]) private var allEntries: [FoodEntry]

    private var repository: FoodRepository { FoodRepository(context: context) }

    var body: some View {
        NavigationStack {
            let dayInterval = DateUtils.dayInterval(for: selectedDate)
            let entries = allEntries.filter { dayInterval.contains($0.timestamp) }

            ZStack {
                WackyBackground()
                List {
                    Section {
                        WackyCard {
                            DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .font(.wackyBody(16))
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
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
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                }
                                .onDelete { indexSet in
                                    delete(items: items, offsets: indexSet)
                                }
                            }
                        }
                    }

                    if entries.isEmpty {
                        Section {
                            WackyCard {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("No entries yet")
                                        .font(.wackyTitle(16))
                                    Text("Tap Add Food to log your first meal.")
                                        .font(.wackyBody(13))
                                        .foregroundStyle(WackyPalette.ink.opacity(0.6))
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .navigationTitle("Daily Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        isPresentingMealPicker = true
                    } label: {
                        Label("Add Meal", systemImage: "fork.knife")
                    }

                    Button {
                        isPresentingAdd = true
                    } label: {
                        Label("Add Food", systemImage: "plus")
                    }
                }
            }
            .tint(WackyPalette.coolBlue)
            .sheet(isPresented: $isPresentingAdd) {
                FoodEntryFormView()
            }
            .sheet(item: $selectedEntry) { entry in
                FoodEntryFormView(entry: entry)
            }
            .sheet(isPresented: $isPresentingMealPicker) {
                MealPickerView(selectedTemplate: $selectedTemplate)
            }
            .sheet(item: $selectedTemplate) { template in
                LogMealView(template: template)
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

struct MealPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @Query(sort: [SortDescriptor(\MealTemplate.lastUsedAt, order: .reverse)]) private var templates: [MealTemplate]

    @Binding var selectedTemplate: MealTemplate?

    var body: some View {
        NavigationStack {
            let filtered = templates.filter { template in
                searchText.isEmpty || template.name.localizedCaseInsensitiveContains(searchText)
            }

            ZStack {
                WackyBackground()
                List(filtered) { template in
                    Button {
                        selectedTemplate = template
                        dismiss()
                    } label: {
                        MealRowView(template: template)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .navigationTitle("Pick Meal")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .tint(WackyPalette.coolBlue)
        }
    }
}

struct EntryRowView: View {
    let entry: FoodEntry
    private var totalCalories: Double { entry.calories * entry.servingsValue }
    private var totalProtein: Double { entry.protein * entry.servingsValue }
    private var totalFat: Double { entry.fat * entry.servingsValue }
    private var totalCarbs: Double { entry.carbs * entry.servingsValue }

    var body: some View {
        WackyCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.name)
                        .font(.wackyTitle(16))
                        .foregroundStyle(WackyPalette.ink)
                    if let serving = entry.serving, !serving.isEmpty {
                        Text(serving)
                            .font(.wackyBody(12))
                            .foregroundStyle(WackyPalette.ink.opacity(0.6))
                    }
                    if entry.servingsValue != 1 {
                        Text("Servings: \(format(entry.servingsValue))")
                            .font(.wackyBody(12))
                            .foregroundStyle(WackyPalette.ink.opacity(0.6))
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(format(totalCalories)) kcal")
                        .font(.wackyMono(13))
                    Text("P \(format(totalProtein))  F \(format(totalFat))  C \(format(totalCarbs))")
                        .font(.wackyCaps(11))
                        .foregroundStyle(WackyPalette.ink.opacity(0.7))
                }
            }
        }
    }

    private func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }
}
