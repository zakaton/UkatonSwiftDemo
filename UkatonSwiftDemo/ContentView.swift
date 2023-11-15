import Combine
import SwiftUI
import UkatonKit

struct ContentView: View {
    private let missionPair: UKMissionPair = .shared

    @State private var isConnectedToPair: Bool = false

    enum TabEnum {
        case deviceDiscovery
        case missionPair

        var requiresMissionPair: Bool {
            switch self {
            case .missionPair:
                true
            default:
                false
            }
        }
    }

    @State private var selectedTab: TabEnum = .deviceDiscovery

    var body: some View {
        TabView(selection: $selectedTab) {
            DeviceDiscovery()
                .tabItem {
                    Label("Device Discovery", systemImage: "magnifyingglass")
                }
                .tag(TabEnum.deviceDiscovery)

            if isConnectedToPair {
                MissionPair(missionPair: missionPair)
                    .tabItem {
                        Label("Mission Pair", systemImage: isConnectedToPair ? "shoe.2" : "xmark")
                    }
                    .tag(TabEnum.missionPair)
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue.requiresMissionPair && !isConnectedToPair {
                selectedTab = oldValue
            }
        }
        .onReceive(missionPair.isConnectedSubject, perform: { isConnectedToPair = $0
        })
    }
}

#Preview {
    ContentView()
        .frame(maxWidth: 400, minHeight: 300)
}
