import Foundation
import SwiftData

@Model
final class FoodEntry {
    @Attribute(.unique) var id: UUID
    var name: String
    var serving: String?
    var servings: Double?
    var calories: Double
    var protein: Double
    var fat: Double
    var carbs: Double
    var timestamp: Date
    var mealTypeRaw: String

    init(
        id: UUID = UUID(),
        name: String,
        serving: String? = nil,
        servings: Double = 1,
        calories: Double,
        protein: Double,
        fat: Double,
        carbs: Double,
        timestamp: Date = Date(),
        mealType: MealType = .other
    ) {
        self.id = id
        self.name = name
        self.serving = serving
        self.servings = servings
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbs = carbs
        self.timestamp = timestamp
        self.mealTypeRaw = mealType.rawValue
    }

    var mealType: MealType {
        get { MealType(rawValue: mealTypeRaw) ?? .other }
        set { mealTypeRaw = newValue.rawValue }
    }

    var servingsValue: Double {
        max(servings ?? 1, 0)
    }
}
