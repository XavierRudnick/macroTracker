import SwiftData

@MainActor
enum ModelContainerFactory {
    static func makeContainer() -> ModelContainer {
        let schema = Schema([
            FoodEntry.self,
            Targets.self
        ])

        let configuration = ModelConfiguration("MacroTracker", schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
