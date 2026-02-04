import Foundation
import SwiftData

@Model
final class MealItem {
    @Attribute(.unique) var id: UUID
    var food: FoodTemplate
    var quantity: Double

    init(id: UUID = UUID(), food: FoodTemplate, quantity: Double) {
        self.id = id
        self.food = food
        self.quantity = quantity
    }
}
