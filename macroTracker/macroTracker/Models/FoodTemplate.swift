import Foundation
import SwiftData

@Model
final class FoodTemplate {
    @Attribute(.unique) var id: UUID
    var name: String
    var serving: String?
    var calories: Double
    var protein: Double
    var fat: Double
    var carbs: Double
    var lastUsedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        serving: String? = nil,
        calories: Double,
        protein: Double,
        fat: Double,
        carbs: Double,
        lastUsedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.serving = serving
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbs = carbs
        self.lastUsedAt = lastUsedAt
    }
}
