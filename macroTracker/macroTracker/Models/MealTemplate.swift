import Foundation
import SwiftData

@Model
final class MealTemplate {
    @Attribute(.unique) var id: UUID
    var name: String
    var items: [MealItem]
    var lastUsedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        items: [MealItem] = [],
        lastUsedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.items = items
        self.lastUsedAt = lastUsedAt
    }

    var totals: MacroTotals {
        items.reduce(into: MacroTotals(calories: 0, protein: 0, fat: 0, carbs: 0)) { result, item in
            let qty = max(item.quantity, 0)
            result.calories += item.food.calories * qty
            result.protein += item.food.protein * qty
            result.fat += item.food.fat * qty
            result.carbs += item.food.carbs * qty
        }
    }
}
