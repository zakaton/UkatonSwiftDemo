import Combine
import SwiftUI
import UkatonKit
import UkatonMacros

struct ContentView: View {
    @ObservedObject private var missionPair: UKMissionPair = .shared

    @EnumName
    enum TabEnum: Identifiable {
        var id: String { name }

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

            MissionPair(missionPair: missionPair)
                .tabItem {
                    Label("Mission Pair", systemImage: missionPair.isConnected ? "shoe.2" : "xmark")
                }
                .tag(TabEnum.missionPair)
        }
//        .tabViewStyle(.page)
//        .onChange(of: selectedTab) { oldValue, newValue in
//            if newValue.requiresMissionPair && !missionPair.isConnected {
//                selectedTab = oldValue
//            }
//        }
    }
}

#Preview {
    ContentView()
        .frame(maxWidth: 400, minHeight: 300)
}
