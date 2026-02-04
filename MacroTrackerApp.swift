import SwiftUI
import SwiftData

@main
struct MacroTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(ModelContainerFactory.makeContainer())
    }
}
