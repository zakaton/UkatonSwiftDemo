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

    var isWatch: Bool {
        #if os(watchOS)
            true
        #else
            false
        #endif
    }

    @State private var selectedTab: TabEnum = .deviceDiscovery

    var body: some View {
        TabView(selection: $selectedTab) {
            DeviceDiscovery()
                .modify {
                    if !isWatch {
                        $0.tabItem {
                            Label("Device Discovery", systemImage: "magnifyingglass")
                        }
                    }
                }
                .tag(TabEnum.deviceDiscovery)

            MissionPair(missionPair: missionPair)
                .modify {
                    if !isWatch {
                        $0.tabItem {
                            Label("Mission Pair", systemImage: missionPair.isConnected ? "shoe.2" : "xmark")
                        }
                    }
                }
                .tag(TabEnum.missionPair)
        }
    }
}

#Preview {
    ContentView()
        .frame(maxWidth: 300, minHeight: 300)
}
