import Foundation

struct MacroTotals: Hashable {
    var calories: Double
    var protein: Double
    var fat: Double
    var carbs: Double
}

enum MacroCalculator {
    static func totals(for entries: [FoodEntry]) -> MacroTotals {
        entries.reduce(into: MacroTotals(calories: 0, protein: 0, fat: 0, carbs: 0)) { result, entry in
            let multiplier = entry.servingsValue
            result.calories += entry.calories * multiplier
            result.protein += entry.protein * multiplier
            result.fat += entry.fat * multiplier
            result.carbs += entry.carbs * multiplier
        }
    }

    static func remaining(for totals: MacroTotals, targets: MacroTargets) -> MacroTotals {
        MacroTotals(
            calories: targets.caloriesTarget - totals.calories,
            protein: targets.proteinTarget - totals.protein,
            fat: targets.fatTarget - totals.fat,
            carbs: targets.carbsTarget - totals.carbs
        )
    }

    static func estimatedCalories(protein: Double, fat: Double, carbs: Double) -> Double {
        4 * protein + 9 * fat + 4 * carbs
    }

    static func discrepancyRatio(calories: Double, protein: Double, fat: Double, carbs: Double) -> Double {
        let estimate = estimatedCalories(protein: protein, fat: fat, carbs: carbs)
        guard estimate > 0 else { return 0 }
        return abs(calories - estimate) / estimate
    }
}
