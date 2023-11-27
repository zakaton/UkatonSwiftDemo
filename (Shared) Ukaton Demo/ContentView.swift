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

    var missionPairImageString: String {
        if missionPair.isConnected {
            return "shoe.2.fill"
        }
        else if missionPair.isHalfConnected {
            return "shoe.fill"
        }
        else {
            return "circle.dashed"
        }
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
                            Label("Mission Pair", systemImage: missionPairImageString)
                        }
                    }
                }
                .tag(TabEnum.missionPair)
        }
    }
}

#Preview {
    ContentView()
    #if os(macOS)
        .frame(maxWidth: 320, minHeight: 300)
    #endif
}
