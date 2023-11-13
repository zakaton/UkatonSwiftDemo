import Combine
import SwiftUI
import UkatonKit

struct ContentView: View {
    @ObservedObject private var missionPair: UKMissionPair = .shared

    @State private var isConnectedToPair: Bool = false
    @State private var hasBothInsoles: Bool = false

    var body: some View {
        TabView {
            DeviceDiscovery()
                .tabItem {
                    Label("Device Discovery", systemImage: "magnifyingglass")
                }
            if hasBothInsoles {
                MissionPair()
                    .tabItem {
                        Label("Mission Pair", systemImage: "shoe.2")
                    }
            }
        }
        .onReceive(missionPair.hasBothInsolesSubject, perform: { hasBothInsoles = $0
        })
    }
}

#Preview {
    ContentView()
        .frame(maxWidth: 350, minHeight: 300)
}
