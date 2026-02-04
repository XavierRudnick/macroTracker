import XCTest

final class MacroCalculatorTests: XCTestCase {
    func testEstimatedCalories() {
        let estimate = MacroCalculator.estimatedCalories(protein: 10, fat: 5, carbs: 20)
        XCTAssertEqual(estimate, 10 * 4 + 5 * 9 + 20 * 4)
    }

    func testDiscrepancyRatioZeroWhenNoMacros() {
        let ratio = MacroCalculator.discrepancyRatio(calories: 100, protein: 0, fat: 0, carbs: 0)
        XCTAssertEqual(ratio, 0)
    }
}
