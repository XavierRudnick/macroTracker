import Foundation
import SwiftData

@Model
final class Targets {
    @Attribute(.unique) var id: UUID
    var caloriesTarget: Double
    var proteinTarget: Double
    var fatTarget: Double
    var carbsTarget: Double

    init(
        id: UUID = UUID(),
        caloriesTarget: Double = MacroTargets.default.caloriesTarget,
        proteinTarget: Double = MacroTargets.default.proteinTarget,
        fatTarget: Double = MacroTargets.default.fatTarget,
        carbsTarget: Double = MacroTargets.default.carbsTarget
    ) {
        self.id = id
        self.caloriesTarget = caloriesTarget
        self.proteinTarget = proteinTarget
        self.fatTarget = fatTarget
        self.carbsTarget = carbsTarget
    }

    var asValue: MacroTargets {
        MacroTargets(
            caloriesTarget: caloriesTarget,
            proteinTarget: proteinTarget,
            fatTarget: fatTarget,
            carbsTarget: carbsTarget
        )
    }

    func apply(_ targets: MacroTargets) {
        caloriesTarget = targets.caloriesTarget
        proteinTarget = targets.proteinTarget
        fatTarget = targets.fatTarget
        carbsTarget = targets.carbsTarget
    }
}
