import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @State private var showShareSheet = false
    @State private var exportURL: URL?
    @State private var isImporting = false
    @State private var importResult: String?

    @State private var caloriesTarget: Double = MacroTargets.default.caloriesTarget
    @State private var proteinTarget: Double = MacroTargets.default.proteinTarget
    @State private var fatTarget: Double = MacroTargets.default.fatTarget
    @State private var carbsTarget: Double = MacroTargets.default.carbsTarget

    private var repository: FoodRepository { FoodRepository(context: context) }

    var body: some View {
        NavigationStack {
            ZStack {
                WackyBackground()
                Form {
                    Section("Targets") {
                        LabeledContent("Calories") {
                            TextField("0", value: $caloriesTarget, format: .number)
                                .keyboardType(.decimalPad)
                        }
                        LabeledContent("Protein (g)") {
                            TextField("0", value: $proteinTarget, format: .number)
                                .keyboardType(.decimalPad)
                        }
                        LabeledContent("Fat (g)") {
                            TextField("0", value: $fatTarget, format: .number)
                                .keyboardType(.decimalPad)
                        }
                        LabeledContent("Carbs (g)") {
                            TextField("0", value: $carbsTarget, format: .number)
                                .keyboardType(.decimalPad)
                        }
                        Button("Save Targets") {
                            saveTargets()
                        }
                    }

                    Section("Backup") {
                        Button("Export Data") {
                            export()
                        }
                        Button("Import Data") {
                            isImporting = true
                        }
                    }

                    if let importResult {
                        Section("Import Result") {
                            Text(importResult)
                                .font(.wackyBody(12))
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listRowBackground(WackyPalette.card.opacity(0.92))
                .font(.wackyBody(15))
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .tint(WackyPalette.coolBlue)
            .sheet(isPresented: $showShareSheet) {
                if let exportURL {
                    ShareSheet(items: [exportURL])
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result)
            }
            .onAppear {
                let targets = repository.targets().asValue
                caloriesTarget = targets.caloriesTarget
                proteinTarget = targets.proteinTarget
                fatTarget = targets.fatTarget
                carbsTarget = targets.carbsTarget
            }
        }
    }

    private func saveTargets() {
        let targets = repository.targets()
        targets.caloriesTarget = caloriesTarget
        targets.proteinTarget = proteinTarget
        targets.fatTarget = fatTarget
        targets.carbsTarget = carbsTarget
        do {
            try context.save()
        } catch {
            return
        }
    }

    private func export() {
        let service = BackupService(repository: repository)
        do {
            exportURL = try service.writeExportFile()
            showShareSheet = true
        } catch {
            importResult = "Export failed."
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        do {
            let urls = try result.get()
            guard let url = urls.first else { return }
            let data = try Data(contentsOf: url)
            let service = BackupService(repository: repository)
            let outcome = try service.importData(data)
            importResult = "Imported \(outcome.inserted) entries. Skipped \(outcome.skipped)."
        } catch {
            importResult = "Import failed."
        }
    }
}
