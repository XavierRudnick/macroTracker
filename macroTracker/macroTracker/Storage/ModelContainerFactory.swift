import Foundation
import SwiftData

@MainActor
enum ModelContainerFactory {
    static func makeContainer() -> ModelContainer {
        let schema = Schema([
            FoodEntry.self,
            FoodTemplate.self,
            MealItem.self,
            MealTemplate.self,
            Targets.self
        ])

        let storeURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("MacroTracker.store")
        let configuration: ModelConfiguration
        if let storeURL {
            configuration = ModelConfiguration("MacroTracker", url: storeURL)
        } else {
            configuration = ModelConfiguration("MacroTracker", isStoredInMemoryOnly: false)
        }
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            if let storeURL {
                try? FileManager.default.removeItem(at: storeURL)
                do {
                    return try ModelContainer(for: schema, configurations: [configuration])
                } catch {
                    fatalError("Failed to recreate ModelContainer after reset: \(error)")
                }
            }
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
