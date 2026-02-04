import SwiftUI
import SwiftData

struct MealsView: View {
    @Environment(\.modelContext) private var context
    @State private var searchText = ""
    @State private var showAddFood = false
    @State private var showAddMeal = false
    @State private var editingFood: FoodTemplate?
    @State private var editingMeal: MealTemplate?
    @State private var expandedFoodID: UUID?
    @State private var expandedMealID: UUID?
    @State private var selectedForLog: FoodTemplate?
    @State private var selectedMealForLog: MealTemplate?

    @Query(sort: [SortDescriptor(\FoodTemplate.lastUsedAt, order: .reverse)]) private var foods: [FoodTemplate]
    @Query(sort: [SortDescriptor(\MealTemplate.lastUsedAt, order: .reverse)]) private var meals: [MealTemplate]

    var body: some View {
        NavigationStack {
            let foodFiltered = foods.filter { template in
                searchText.isEmpty || template.name.localizedCaseInsensitiveContains(searchText)
            }
            let mealFiltered = meals.filter { template in
                searchText.isEmpty || template.name.localizedCaseInsensitiveContains(searchText)
            }

            ZStack {
                WackyBackground()
                List {
                    Section("Foods") {
                        ForEach(foodFiltered) { food in
                            FoodTemplateRow(
                                template: food,
                                isExpanded: expandedFoodID == food.id,
                                onToggle: { toggleFood(food.id) },
                                onLog: { selectedForLog = food },
                                onEdit: { editingFood = food },
                                onDelete: { delete(food) }
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }

                    Section("Meals") {
                        ForEach(mealFiltered) { meal in
                            MealTemplateRow(
                                template: meal,
                                isExpanded: expandedMealID == meal.id,
                                onToggle: { toggleMeal(meal.id) },
                                onLog: { selectedMealForLog = meal },
                                onEdit: { editingMeal = meal },
                                onDelete: { delete(meal) }
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .navigationTitle("Meals")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        showAddFood = true
                    } label: {
                        Label("Add Food", systemImage: "leaf")
                    }
                    Button {
                        showAddMeal = true
                    } label: {
                        Label("Add Meal", systemImage: "fork.knife")
                    }
                }
            }
            .tint(WackyPalette.coolBlue)
            .sheet(isPresented: $showAddFood) {
                FoodTemplateFormView()
            }
            .sheet(isPresented: $showAddMeal) {
                MealTemplateFormView()
            }
            .sheet(item: $editingFood) { template in
                FoodTemplateFormView(template: template)
            }
            .sheet(item: $editingMeal) { template in
                MealTemplateFormView(template: template)
            }
            .sheet(item: $selectedForLog) { template in
                LogFoodView(template: template)
            }
            .sheet(item: $selectedMealForLog) { template in
                LogMealView(template: template)
            }
        }
    }

    private func toggleFood(_ id: UUID) {
        expandedFoodID = (expandedFoodID == id) ? nil : id
    }

    private func toggleMeal(_ id: UUID) {
        expandedMealID = (expandedMealID == id) ? nil : id
    }

    private func delete(_ template: FoodTemplate) {
        context.delete(template)
        try? context.save()
    }

    private func delete(_ template: MealTemplate) {
        context.delete(template)
        try? context.save()
    }
}

struct FoodTemplateRow: View {
    let template: FoodTemplate
    let isExpanded: Bool
    let onToggle: () -> Void
    let onLog: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        WackyCard {
            VStack(alignment: .leading, spacing: 10) {
                Button(action: onToggle) {
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
                .buttonStyle(.plain)

                if isExpanded {
                    HStack(spacing: 8) {
                        ActionPill(label: "Log", systemImage: "plus.circle.fill", tint: WackyPalette.mutedGreen, action: onLog)
                        ActionPill(label: "Edit", systemImage: "pencil", tint: WackyPalette.coolBlue, action: onEdit)
                        ActionPill(label: "Delete", systemImage: "trash", tint: .red, action: onDelete, isDestructive: true)
                    }
                }
            }
        }
    }

    private func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }
}

struct MealTemplateRow: View {
    let template: MealTemplate
    let isExpanded: Bool
    let onToggle: () -> Void
    let onLog: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        WackyCard {
            VStack(alignment: .leading, spacing: 10) {
                Button(action: onToggle) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.name)
                                .font(.wackyTitle(16))
                                .foregroundStyle(WackyPalette.ink)
                            Text("\(template.items.count) foods")
                                .font(.wackyBody(12))
                                .foregroundStyle(WackyPalette.ink.opacity(0.6))
                        }
                        Spacer()
                        let totals = template.totals
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(format(totals.calories)) kcal")
                                .font(.wackyMono(13))
                            Text("P \(format(totals.protein))  F \(format(totals.fat))  C \(format(totals.carbs))")
                                .font(.wackyCaps(11))
                                .foregroundStyle(WackyPalette.ink.opacity(0.7))
                        }
                    }
                }
                .buttonStyle(.plain)

                if isExpanded {
                    HStack(spacing: 8) {
                        ActionPill(label: "Log", systemImage: "plus.circle.fill", tint: WackyPalette.mutedGreen, action: onLog)
                        ActionPill(label: "Edit", systemImage: "pencil", tint: WackyPalette.coolBlue, action: onEdit)
                        ActionPill(label: "Delete", systemImage: "trash", tint: .red, action: onDelete, isDestructive: true)
                    }
                }
            }
        }
    }

    private func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }
}

struct ActionPill: View {
    let label: String
    let systemImage: String
    let tint: Color
    let action: () -> Void
    var isDestructive: Bool = false

    var body: some View {
        Button(action: action) {
            Label(label, systemImage: systemImage)
                .font(.wackyCaps(12))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule(style: .continuous)
                        .fill(tint.opacity(isDestructive ? 0.2 : 0.25))
                )
                .foregroundStyle(WackyPalette.ink)
        }
        .buttonStyle(.plain)
    }
}

struct FoodTemplateFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let template: FoodTemplate?

    @State private var name: String = ""
    @State private var serving: String = ""
    @State private var calories: Double = 0
    @State private var protein: Double = 0
    @State private var fat: Double = 0
    @State private var carbs: Double = 0
    @State private var showValidationAlert = false
    @State private var didLoad = false

    init(template: FoodTemplate? = nil) {
        self.template = template
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WackyBackground()
                Form {
                    Section("Food") {
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
            .navigationTitle(template == nil ? "Add Food" : "Edit Food")
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
            .onAppear {
                guard !didLoad else { return }
                didLoad = true
                if let template {
                    name = template.name
                    serving = template.serving ?? ""
                    calories = template.calories
                    protein = template.protein
                    fat = template.fat
                    carbs = template.carbs
                }
            }
        }
    }

    private func save() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showValidationAlert = true
            return
        }

        if let template {
            template.name = name
            template.serving = serving.isEmpty ? nil : serving
            template.calories = calories
            template.protein = protein
            template.fat = fat
            template.carbs = carbs
        } else {
            let template = FoodTemplate(
                name: name,
                serving: serving.isEmpty ? nil : serving,
                calories: calories,
                protein: protein,
                fat: fat,
                carbs: carbs
            )
            context.insert(template)
        }
        try? context.save()
        dismiss()
    }
}

struct MealTemplateFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let template: MealTemplate?

    @State private var name: String = ""
    @State private var showValidationAlert = false
    @State private var didLoad = false
    @State private var showAddItem = false

    @Query(sort: [SortDescriptor(\FoodTemplate.name, order: .forward)]) private var foods: [FoodTemplate]

    init(template: MealTemplate? = nil) {
        self.template = template
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WackyBackground()
                Form {
                    Section("Meal") {
                        TextField("Name", text: $name)
                    }

                    Section("Foods") {
                        if currentItems.isEmpty {
                            Text("Add foods to build this meal.")
                                .font(.wackyBody(12))
                                .foregroundStyle(WackyPalette.ink.opacity(0.6))
                        } else {
                            ForEach(currentItems) { item in
                                HStack {
                                    Text(item.food.name)
                                        .font(.wackyBody(14))
                                    Spacer()
                                    Stepper(value: binding(for: item), in: 0...20, step: 0.5) {
                                        Text("\(format(item.quantity))x")
                                            .font(.wackyMono(12))
                                    }
                                }
                            }
                            .onDelete(perform: deleteItem)
                        }

                        Button {
                            showAddItem = true
                        } label: {
                            Label("Add Food", systemImage: "plus")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listRowBackground(WackyPalette.card.opacity(0.92))
                .font(.wackyBody(15))
            }
            .navigationTitle(template == nil ? "Add Meal" : "Edit Meal")
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
            .sheet(isPresented: $showAddItem) {
                AddMealItemView(foods: foods, onAdd: addFoodItem)
            }
            .onAppear {
                guard !didLoad else { return }
                didLoad = true
                if let template {
                    name = template.name
                }
            }
        }
    }

    private var currentItems: [MealItem] {
        template?.items ?? draftItems
    }

    @State private var draftItems: [MealItem] = []

    private func addFoodItem(_ food: FoodTemplate, quantity: Double) {
        let item = MealItem(food: food, quantity: quantity)
        if let template {
            context.insert(item)
            template.items.append(item)
        } else {
            draftItems.append(item)
        }
    }

    private func deleteItem(at offsets: IndexSet) {
        if let template {
            let removed = offsets.map { template.items[$0] }
            template.items.remove(atOffsets: offsets)
            for item in removed {
                context.delete(item)
            }
        } else {
            draftItems.remove(atOffsets: offsets)
        }
    }

    private func binding(for item: MealItem) -> Binding<Double> {
        Binding(
            get: { item.quantity },
            set: { newValue in
                item.quantity = newValue
            }
        )
    }

    private func save() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showValidationAlert = true
            return
        }

        if let template {
            template.name = name
        } else {
            let template = MealTemplate(name: name)
            context.insert(template)
            for item in draftItems {
                context.insert(item)
            }
            template.items = draftItems
        }
        try? context.save()
        dismiss()
    }

    private func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }
}

struct AddMealItemView: View {
    @Environment(\.dismiss) private var dismiss
    let foods: [FoodTemplate]
    let onAdd: (FoodTemplate, Double) -> Void

    @State private var searchText = ""
    @State private var selectedFood: FoodTemplate?
    @State private var quantity: Double = 1

    var body: some View {
        NavigationStack {
            let filtered = foods.filter { food in
                searchText.isEmpty || food.name.localizedCaseInsensitiveContains(searchText)
            }

            ZStack {
                WackyBackground()
                List(filtered) { food in
                    Button {
                        selectedFood = food
                    } label: {
                        HStack {
                            Text(food.name)
                                .font(.wackyBody(14))
                            Spacer()
                            if selectedFood?.id == food.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(WackyPalette.mutedGreen)
                            } else {
                                Text("\(format(food.calories)) kcal")
                                    .font(.wackyMono(12))
                                    .foregroundStyle(WackyPalette.ink.opacity(0.7))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard let selectedFood else { return }
                        onAdd(selectedFood, quantity)
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    if let selectedFood {
                        Text("Adding \(selectedFood.name)")
                            .font(.wackyBody(14))
                    } else {
                        Text("Pick a food")
                            .font(.wackyBody(14))
                            .foregroundStyle(WackyPalette.ink.opacity(0.7))
                    }
                    Spacer()
                    Stepper(value: $quantity, in: 0...20, step: 0.5) {
                        Text("\(format(quantity))x")
                            .font(.wackyMono(12))
                    }
                }
                .padding()
                .background(WackyPalette.cardAlt)
            }
            .tint(WackyPalette.coolBlue)
        }
    }

    private func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }
}

struct LogFoodView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let template: FoodTemplate

    @State private var servings: Double = 1
    @State private var timestamp: Date = Date()
    @State private var mealType: MealType = .other

    var body: some View {
        NavigationStack {
            let multiplier = max(servings, 0)
            ZStack {
                WackyBackground()
                Form {
                    Section("Food") {
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
            .navigationTitle("Log Food")
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
        try? context.save()
        dismiss()
    }

    private func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
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
            let totals = template.totals
            ZStack {
                WackyBackground()
                Form {
                    Section("Meal") {
                        HStack {
                            Text(template.name)
                                .font(.wackyTitle(16))
                            Spacer()
                            Text("\(format(totals.calories)) kcal")
                                .font(.wackyMono(12))
                        }
                        Text("\(template.items.count) foods")
                            .font(.wackyBody(12))
                            .foregroundStyle(WackyPalette.ink.opacity(0.6))
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
                        Text("Calories \(format(totals.calories * multiplier)) kcal")
                            .font(.wackyBody(13))
                        Text("Protein \(format(totals.protein * multiplier)) g • Fat \(format(totals.fat * multiplier)) g • Carbs \(format(totals.carbs * multiplier)) g")
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
    }

    private func save() {
        let totals = template.totals
        let entry = FoodEntry(
            name: template.name,
            serving: "Meal",
            servings: max(servings, 0),
            calories: totals.calories,
            protein: totals.protein,
            fat: totals.fat,
            carbs: totals.carbs,
            timestamp: timestamp,
            mealType: mealType
        )
        context.insert(entry)
        template.lastUsedAt = Date()
        try? context.save()
        dismiss()
    }

    private func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }
}
