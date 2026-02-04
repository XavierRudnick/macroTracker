import SwiftUI

struct RecentsView: View {
    @Environment(\.modelContext) private var context
    @State private var searchText = ""
    @State private var selectedTemplate: FoodEntry?

    private var repository: FoodRepository { FoodRepository(context: context) }

    var body: some View {
        NavigationStack {
            let entries = repository.recentEntries(limit: 50)
            let filtered = entries.filter { entry in
                searchText.isEmpty || entry.name.localizedCaseInsensitiveContains(searchText)
            }

            List(filtered) { entry in
                Button {
                    selectedTemplate = entry
                } label: {
                    EntryRowView(entry: entry)
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Recents")
            .searchable(text: $searchText)
            .sheet(item: $selectedTemplate) { entry in
                FoodEntryFormView(template: entry)
            }
        }
    }
}
