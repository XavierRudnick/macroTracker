import Foundation
import SwiftData

@MainActor
final class FoodRepository {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func addEntry(_ entry: FoodEntry) throws {
        context.insert(entry)
        try context.save()
    }

    func deleteEntry(_ entry: FoodEntry) throws {
        context.delete(entry)
        try context.save()
    }

    func entries(on date: Date) -> [FoodEntry] {
        entries(in: DateUtils.dayInterval(for: date))
    }

    func entries(in interval: DateInterval) -> [FoodEntry] {
        let predicate = #Predicate<FoodEntry> { entry in
            entry.timestamp >= interval.start && entry.timestamp < interval.end
        }
        let descriptor = FetchDescriptor<FoodEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func allEntries() -> [FoodEntry] {
        let descriptor = FetchDescriptor<FoodEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func recentEntries(limit: Int) -> [FoodEntry] {
        var descriptor = FetchDescriptor<FoodEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? context.fetch(descriptor)) ?? []
    }

    func targets() -> Targets {
        let descriptor = FetchDescriptor<Targets>()
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let newTargets = Targets()
        context.insert(newTargets)
        return newTargets
    }

    func findEntry(id: UUID) -> FoodEntry? {
        let predicate = #Predicate<FoodEntry> { entry in
            entry.id == id
        }
        let descriptor = FetchDescriptor<FoodEntry>(predicate: predicate)
        return (try? context.fetch(descriptor))?.first
    }

    func insertIfMissing(_ entry: FoodEntry) throws -> Bool {
        if findEntry(id: entry.id) != nil {
            return false
        }
        context.insert(entry)
        try context.save()
        return true
    }

    // Meal templates
    func findMealTemplate(id: UUID) -> MealTemplate? {
        let predicate = #Predicate<MealTemplate> { template in
            template.id == id
        }
        let descriptor = FetchDescriptor<MealTemplate>(predicate: predicate)
        return (try? context.fetch(descriptor))?.first
    }

    func insertMealTemplateIfMissing(_ template: MealTemplate) throws -> Bool {
        if findMealTemplate(id: template.id) != nil {
            return false
        }
        context.insert(template)
        try context.save()
        return true
    }
}
