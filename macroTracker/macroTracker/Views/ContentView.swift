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

            MealsView()
                .tabItem {
                    Label("Meals", systemImage: "fork.knife")
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
        .tint(WackyPalette.coolBlue)
        .toolbarBackground(WackyPalette.cream, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
