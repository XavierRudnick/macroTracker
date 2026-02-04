import SwiftUI
import SwiftData

struct FoodEntryFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let entry: FoodEntry?
    let template: FoodEntry?

    @State private var name: String = ""
    @State private var serving: String = ""
    @State private var servings: Double = 1
    @State private var calories: Double = 0
    @State private var protein: Double = 0
    @State private var fat: Double = 0
    @State private var carbs: Double = 0
    @State private var timestamp: Date = Date()
    @State private var mealType: MealType = .other
    @State private var showValidationAlert = false
    @State private var didLoad = false

    private var repository: FoodRepository { FoodRepository(context: context) }

    init(entry: FoodEntry? = nil, template: FoodEntry? = nil) {
        self.entry = entry
        self.template = template
    }

    var body: some View {
        NavigationStack {
            let multiplier = max(servings, 0)
            ZStack {
                WackyBackground()
                Form {
                    Section("Food") {
                        TextField("Name", text: $name)
                        TextField("Serving size (optional)", text: $serving)
                        LabeledContent("Servings") {
                            TextField("1", value: $servings, format: .number)
                                .keyboardType(.decimalPad)
                        }
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

                    Section("Details") {
                        DatePicker("Time", selection: $timestamp)
                        Picker("Meal", selection: $mealType) {
                            ForEach(MealType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                    }

                    if servings != 1 {
                        Section("Totals") {
                            Text("Calories \(format(calories * multiplier)) kcal")
                                .font(.wackyBody(13))
                            Text("Protein \(format(protein * multiplier)) g • Fat \(format(fat * multiplier)) g • Carbs \(format(carbs * multiplier)) g")
                                .font(.wackyBody(13))
                                .foregroundStyle(WackyPalette.ink.opacity(0.7))
                        }
                    }

                    if MacroCalculator.discrepancyRatio(calories: calories, protein: protein, fat: fat, carbs: carbs) > 0.2 {
                        Section {
                            Text("Macros estimate \(Int(MacroCalculator.estimatedCalories(protein: protein, fat: fat, carbs: carbs))) kcal. That differs by more than 20% from the calorie value.")
                                .font(.wackyBody(12))
                                .foregroundStyle(.orange)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listRowBackground(WackyPalette.card.opacity(0.92))
                .font(.wackyBody(15))
            }
            .navigationTitle(entry == nil ? "Add Food" : "Edit Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                }
            }
            .tint(WackyPalette.coolBlue)
            .alert("Name is required", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) { }
            }
            .onAppear {
                guard !didLoad else { return }
                didLoad = true
                if let entry {
                    name = entry.name
                    serving = entry.serving ?? ""
                    servings = entry.servingsValue
                    calories = entry.calories
                    protein = entry.protein
                    fat = entry.fat
                    carbs = entry.carbs
                    timestamp = entry.timestamp
                    mealType = entry.mealType
                } else if let template {
                    name = template.name
                    serving = template.serving ?? ""
                    servings = template.servingsValue
                    calories = template.calories
                    protein = template.protein
                    fat = template.fat
                    carbs = template.carbs
                    timestamp = Date()
                    mealType = template.mealType
                }
            }
        }
    }

    private func save() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showValidationAlert = true
            return
        }

        if let entry {
            entry.name = name
            entry.serving = serving.isEmpty ? nil : serving
            entry.servings = max(servings, 0)
            entry.calories = calories
            entry.protein = protein
            entry.fat = fat
            entry.carbs = carbs
            entry.timestamp = timestamp
            entry.mealType = mealType
            do {
                try context.save()
            } catch {
                return
            }
        } else {
            let newEntry = FoodEntry(
                name: name,
                serving: serving.isEmpty ? nil : serving,
                servings: max(servings, 0),
                calories: calories,
                protein: protein,
                fat: fat,
                carbs: carbs,
                timestamp: timestamp,
                mealType: mealType
            )
            do {
                try repository.addEntry(newEntry)
            } catch {
                return
            }
        }
        dismiss()
    }

    private func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }
}
