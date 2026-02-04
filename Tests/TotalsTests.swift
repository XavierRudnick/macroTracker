import XCTest

final class TotalsTests: XCTestCase {
    func testTotalsAndRemaining() {
        let entries = [
            FoodEntry(name: "Test", calories: 200, protein: 20, fat: 5, carbs: 10),
            FoodEntry(name: "Test2", calories: 300, protein: 10, fat: 10, carbs: 30)
        ]
        let totals = MacroCalculator.totals(for: entries)
        XCTAssertEqual(totals.calories, 500)
        XCTAssertEqual(totals.protein, 30)
        XCTAssertEqual(totals.fat, 15)
        XCTAssertEqual(totals.carbs, 40)

        let remaining = MacroCalculator.remaining(for: totals, targets: .default)
        XCTAssertEqual(remaining.calories, MacroTargets.default.caloriesTarget - 500)
        XCTAssertEqual(remaining.protein, MacroTargets.default.proteinTarget - 30)
        XCTAssertEqual(remaining.fat, MacroTargets.default.fatTarget - 15)
        XCTAssertEqual(remaining.carbs, MacroTargets.default.carbsTarget - 40)
    }
}
