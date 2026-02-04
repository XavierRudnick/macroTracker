import Foundation
import SwiftData

struct FoodEntryDTO: Codable, Hashable {
    var id: UUID
    var name: String
    var serving: String?
    var servings: Double?
    var calories: Double
    var protein: Double
    var fat: Double
    var carbs: Double
    var timestamp: Date
    var mealType: MealType

    init(from entry: FoodEntry) {
        id = entry.id
        name = entry.name
        serving = entry.serving
        servings = entry.servings
        calories = entry.calories
        protein = entry.protein
        fat = entry.fat
        carbs = entry.carbs
        timestamp = entry.timestamp
        mealType = entry.mealType
    }

    func toModel() -> FoodEntry {
        FoodEntry(
            id: id,
            name: name,
            serving: serving,
            servings: servings ?? 1,
            calories: calories,
            protein: protein,
            fat: fat,
            carbs: carbs,
            timestamp: timestamp,
            mealType: mealType
        )
    }
}

struct FoodTemplateDTO: Codable, Hashable {
    var id: UUID
    var name: String
    var serving: String?
    var calories: Double
    var protein: Double
    var fat: Double
    var carbs: Double
    var lastUsedAt: Date

    init(from template: FoodTemplate) {
        id = template.id
        name = template.name
        serving = template.serving
        calories = template.calories
        protein = template.protein
        fat = template.fat
        carbs = template.carbs
        lastUsedAt = template.lastUsedAt
    }

    func toModel() -> FoodTemplate {
        FoodTemplate(
            id: id,
            name: name,
            serving: serving,
            calories: calories,
            protein: protein,
            fat: fat,
            carbs: carbs,
            lastUsedAt: lastUsedAt
        )
    }
}

struct MealItemDTO: Codable, Hashable {
    var foodID: UUID
    var quantity: Double
}

struct MealTemplateDTO: Codable, Hashable {
    var id: UUID
    var name: String
    var lastUsedAt: Date
    var items: [MealItemDTO]

    init(from template: MealTemplate) {
        id = template.id
        name = template.name
        lastUsedAt = template.lastUsedAt
        items = template.items.map { MealItemDTO(foodID: $0.food.id, quantity: $0.quantity) }
    }
}

struct BackupPayload: Codable {
    var schemaVersion: Int
    var targets: MacroTargets
    var entries: [FoodEntryDTO]
    var foodTemplates: [FoodTemplateDTO]?
    var mealTemplates: [MealTemplateDTO]?
}

enum BackupError: Error {
    case unsupportedSchema
    case invalidData
}

@MainActor
final class BackupService {
    static let currentSchemaVersion = 4

    private let repository: FoodRepository

    init(repository: FoodRepository) {
        self.repository = repository
    }

    func exportData() throws -> Data {
        let targets = repository.targets().asValue
        let entries = repository.allEntries().map(FoodEntryDTO.init)
        let foodTemplates = (try? repository.context.fetch(FetchDescriptor<FoodTemplate>()))?.map(FoodTemplateDTO.init) ?? []
        let mealTemplates = (try? repository.context.fetch(FetchDescriptor<MealTemplate>()))?.map(MealTemplateDTO.init) ?? []
        let payload = BackupPayload(
            schemaVersion: Self.currentSchemaVersion,
            targets: targets,
            entries: entries,
            foodTemplates: foodTemplates.isEmpty ? nil : foodTemplates,
            mealTemplates: mealTemplates.isEmpty ? nil : mealTemplates
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(payload)
    }

    func writeExportFile() throws -> URL {
        let data = try exportData()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let filename = "macro-tracker-backup-\(formatter.string(from: Date())).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try data.write(to: url, options: [.atomic])
        return url
    }

    static func decodePayload(_ data: Data) throws -> BackupPayload {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(BackupPayload.self, from: data)
    }

    func importData(_ data: Data) throws -> (inserted: Int, skipped: Int) {
        let payload = try Self.decodePayload(data)
        guard payload.schemaVersion <= Self.currentSchemaVersion else {
            throw BackupError.unsupportedSchema
        }

        let targets = repository.targets()
        targets.apply(payload.targets)

        var inserted = 0
        var skipped = 0
        for dto in payload.entries {
            let model = dto.toModel()
            let didInsert = try repository.insertIfMissing(model)
            if didInsert {
                inserted += 1
            } else {
                skipped += 1
            }
        }

        var foodMap: [UUID: FoodTemplate] = [:]
        if let foodTemplates = payload.foodTemplates {
            for dto in foodTemplates {
                let model = dto.toModel()
                _ = try repository.insertFoodTemplateIfMissing(model)
                if let saved = repository.findFoodTemplate(id: model.id) {
                    foodMap[model.id] = saved
                }
            }
        }

        if let mealTemplates = payload.mealTemplates {
            for dto in mealTemplates {
                let items = dto.items.compactMap { itemDTO -> MealItem? in
                    guard let food = foodMap[itemDTO.foodID] else { return nil }
                    return MealItem(food: food, quantity: itemDTO.quantity)
                }
                let model = MealTemplate(id: dto.id, name: dto.name, items: items, lastUsedAt: dto.lastUsedAt)
                _ = try repository.insertMealTemplateIfMissing(model)
            }
        }
        return (inserted, skipped)
    }
}
