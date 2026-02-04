import XCTest

final class BackupServiceTests: XCTestCase {
    func testBackupEncodingDecoding() throws {
        let entry = FoodEntryDTO(
            id: UUID(),
            name: "Test",
            serving: nil,
            servings: 2,
            calories: 100,
            protein: 10,
            fat: 2,
            carbs: 15,
            timestamp: Date(timeIntervalSince1970: 0),
            mealType: .breakfast
        )
        let payload = BackupPayload(
            schemaVersion: BackupService.currentSchemaVersion,
            targets: .default,
            entries: [entry]
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)

        let decoded = try BackupService.decodePayload(data)
        XCTAssertEqual(decoded.schemaVersion, BackupService.currentSchemaVersion)
        XCTAssertEqual(decoded.entries.count, 1)
        XCTAssertEqual(decoded.entries.first?.name, "Test")
    }
}
