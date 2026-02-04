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

struct MealTemplateDTO: Codable, Hashable {
    var id: UUID
    var name: String
    var serving: String?
    var calories: Double
    var protein: Double
    var fat: Double
    var carbs: Double
    var lastUsedAt: Date

    init(from template: MealTemplate) {
        id = template.id
        name = template.name
        serving = template.serving
        calories = template.calories
        protein = template.protein
        fat = template.fat
        carbs = template.carbs
        lastUsedAt = template.lastUsedAt
    }

    func toModel() -> MealTemplate {
        MealTemplate(
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

struct BackupPayload: Codable {
    var schemaVersion: Int
    var targets: MacroTargets
    var entries: [FoodEntryDTO]
    var mealTemplates: [MealTemplateDTO]?
}

enum BackupError: Error {
    case unsupportedSchema
    case invalidData
}

@MainActor
final class BackupService {
    static let currentSchemaVersion = 3

    private let repository: FoodRepository

    init(repository: FoodRepository) {
        self.repository = repository
    }

    func exportData() throws -> Data {
        let targets = repository.targets().asValue
        let entries = repository.allEntries().map(FoodEntryDTO.init)
        let templates = (try? repository.context.fetch(FetchDescriptor<MealTemplate>()))?.map(MealTemplateDTO.init) ?? []
        let payload = BackupPayload(
            schemaVersion: Self.currentSchemaVersion,
            targets: targets,
            entries: entries,
            mealTemplates: templates.isEmpty ? nil : templates
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

        if let templates = payload.mealTemplates {
            for dto in templates {
                let model = dto.toModel()
                _ = try repository.insertMealTemplateIfMissing(model)
            }
        }
        return (inserted, skipped)
    }
}
