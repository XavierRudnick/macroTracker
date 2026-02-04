import SwiftUI
import SwiftData

struct MealsView: View {
    @Environment(\.modelContext) private var context
    @State private var searchText = ""
    @State private var selectedTemplate: MealTemplate?
    @State private var isPresentingAdd = false
    @Query(sort: [SortDescriptor(\MealTemplate.lastUsedAt, order: .reverse)]) private var templates: [MealTemplate]

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
            .navigationTitle("Meals")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText)
            .toolbar {
                Button {
                    isPresentingAdd = true
                } label: {
                    Label("Add Meal", systemImage: "plus")
                }
            }
            .tint(WackyPalette.coolBlue)
            .sheet(isPresented: $isPresentingAdd) {
                MealTemplateFormView()
            }
            .sheet(item: $selectedTemplate) { template in
                LogMealView(template: template)
            }
        }
    }
}

struct MealRowView: View {
    let template: MealTemplate

    var body: some View {
        WackyCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.wackyTitle(16))
                        .foregroundStyle(WackyPalette.ink)
                    if let serving = template.serving, !serving.isEmpty {
                        Text(serving)
                            .font(.wackyBody(12))
                            .foregroundStyle(WackyPalette.ink.opacity(0.6))
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(format(template.calories)) kcal")
                        .font(.wackyMono(13))
                    Text("P \(format(template.protein))  F \(format(template.fat))  C \(format(template.carbs))")
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

struct MealTemplateFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var serving: String = ""
    @State private var calories: Double = 0
    @State private var protein: Double = 0
    @State private var fat: Double = 0
    @State private var carbs: Double = 0
    @State private var showValidationAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                WackyBackground()
                Form {
                    Section("Meal") {
                        TextField("Name", text: $name)
                        TextField("Serving size (optional)", text: $serving)
                    }
                    Section("Macros (per serving)") {
                        LabeledContent("Calories") {
                            TextField("0", value: $calories, format: .number)
                                .keyboardType(.decimalPad)
                        }
                        LabeledContent("Protein (g)") {
                            TextField("0", value: $protein, format: .number)
                                .keyboardType(.decimalPad)
                        }
                        LabeledContent("Fat (g)") {
                            TextField("0", value: $fat, format: .number)
                                .keyboardType(.decimalPad)
                        }
                        LabeledContent("Carbs (g)") {
                            TextField("0", value: $carbs, format: .number)
                                .keyboardType(.decimalPad)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listRowBackground(WackyPalette.card.opacity(0.92))
                .font(.wackyBody(15))
            }
            .navigationTitle("Add Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
            .tint(WackyPalette.coolBlue)
            .alert("Name is required", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }

    private func save() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showValidationAlert = true
            return
        }

        let template = MealTemplate(
            name: name,
            serving: serving.isEmpty ? nil : serving,
            calories: calories,
            protein: protein,
            fat: fat,
            carbs: carbs
        )
        context.insert(template)
        do {
            try context.save()
        } catch {
            return
        }
        dismiss()
    }
}

struct LogMealView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let template: MealTemplate

    @State private var servings: Double = 1
    @State private var timestamp: Date = Date()
    @State private var mealType: MealType = .other

    var body: some View {
        NavigationStack {
            let multiplier = max(servings, 0)
            ZStack {
                WackyBackground()
                Form {
                    Section("Meal") {
                        HStack {
                            Text(template.name)
                                .font(.wackyTitle(16))
                            Spacer()
                            Text("\(format(template.calories)) kcal")
                                .font(.wackyMono(12))
                        }
                        if let serving = template.serving, !serving.isEmpty {
                            Text(serving)
                                .font(.wackyBody(12))
                                .foregroundStyle(WackyPalette.ink.opacity(0.6))
                        }
                    }

                    Section("Servings") {
                        TextField("1", value: $servings, format: .number)
                            .keyboardType(.decimalPad)
                    }

                    Section("Details") {
                        DatePicker("Time", selection: $timestamp)
                        Picker("Meal", selection: $mealType) {
                            ForEach(MealType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                    }

                    Section("Totals") {
                        Text("Calories \(format(template.calories * multiplier)) kcal")
                            .font(.wackyBody(13))
                        Text("Protein \(format(template.protein * multiplier)) g • Fat \(format(template.fat * multiplier)) g • Carbs \(format(template.carbs * multiplier)) g")
                            .font(.wackyBody(13))
                            .foregroundStyle(WackyPalette.ink.opacity(0.7))
                    }
                }
                .scrollContentBackground(.hidden)
                .listRowBackground(WackyPalette.card.opacity(0.92))
                .font(.wackyBody(15))
            }
            .navigationTitle("Log Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
            .tint(WackyPalette.coolBlue)
        }
        .onAppear {
            servings = 1
        }
    }

    private func save() {
        let entry = FoodEntry(
            name: template.name,
            serving: template.serving,
            servings: max(servings, 0),
            calories: template.calories,
            protein: template.protein,
            fat: template.fat,
            carbs: template.carbs,
            timestamp: timestamp,
            mealType: mealType
        )
        context.insert(entry)
        template.lastUsedAt = Date()
        do {
            try context.save()
        } catch {
            return
        }
        dismiss()
    }

    private func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }
}
