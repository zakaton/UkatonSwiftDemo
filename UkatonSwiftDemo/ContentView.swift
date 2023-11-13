import SwiftUI

struct ContentView: View {
    @StateObject private var navigationCoordinator = NavigationCoordinator()

    var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
            TabView {
                DeviceDiscovery()
                    .tabItem {
                        Label("Device Discovery", systemImage: "magnifyingglass")
                    }
                MissionsPair()
                    .tabItem {
                        Label("My Missions", systemImage: "shoe.2")
                    }
            }
        }
        .environmentObject(navigationCoordinator)
    }
}

#Preview {
    ContentView()
        .frame(maxWidth: 350, minHeight: 300)
}
