import XCTest

final class TotalsTests: XCTestCase {
    func testTotalsAndRemaining() {
        let entries = [
            FoodEntry(name: "Test", servings: 2, calories: 200, protein: 20, fat: 5, carbs: 10),
            FoodEntry(name: "Test2", servings: 1, calories: 300, protein: 10, fat: 10, carbs: 30)
        ]
        let totals = MacroCalculator.totals(for: entries)
        XCTAssertEqual(totals.calories, 700)
        XCTAssertEqual(totals.protein, 50)
        XCTAssertEqual(totals.fat, 20)
        XCTAssertEqual(totals.carbs, 50)

        let remaining = MacroCalculator.remaining(for: totals, targets: .default)
        XCTAssertEqual(remaining.calories, MacroTargets.default.caloriesTarget - 700)
        XCTAssertEqual(remaining.protein, MacroTargets.default.proteinTarget - 50)
        XCTAssertEqual(remaining.fat, MacroTargets.default.fatTarget - 20)
        XCTAssertEqual(remaining.carbs, MacroTargets.default.carbsTarget - 50)
    }
}
