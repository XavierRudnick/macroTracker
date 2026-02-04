import Foundation

struct MacroTargets: Codable, Hashable {
    var caloriesTarget: Double
    var proteinTarget: Double
    var fatTarget: Double
    var carbsTarget: Double

    static let `default` = MacroTargets(
        caloriesTarget: 2700,
        proteinTarget: 150,
        fatTarget: 80,
        carbsTarget: 345
    )
}
