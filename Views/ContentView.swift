import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "gauge")
                }

            DailyLogView()
                .tabItem {
                    Label("Log", systemImage: "list.bullet.rectangle")
                }

            RecentsView()
                .tabItem {
                    Label("Recents", systemImage: "clock")
                }

            WeeklyView()
                .tabItem {
                    Label("Weekly", systemImage: "calendar")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
}
