import Combine
import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros

extension URL {
    var isDeeplink: Bool {
        return scheme == "ukaton-demo" // matches ukaton-demo://<rest-of-the-url>
    }
}

@StaticLogger
struct ContentView: View {
    @ObservedObject private var missionPair: UKMissionPair = .shared

    @StateObject private var deviceDiscoveryNavigationCoordinator: NavigationCoordinator = .init()

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
            DeviceDiscovery(navigationCoordinator: deviceDiscoveryNavigationCoordinator)
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
        .onOpenURL { incomingURL in
            logger.debug("App was opened via URL: \(incomingURL)")
            handleIncomingURL(incomingURL)
        }
        .modify {
            #if os(macOS)
                $0.onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { _ in
                    // UKDevicesInformation.shared.clear()
                }
            #endif
        }
    }

    private func handleIncomingURL(_ url: URL) {
        guard url.isDeeplink else {
            return
        }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let action = components.host
        else {
            logger.debug("Invalid URL")
            return
        }

        switch action {
        case "select-device":
            selectedTab = .deviceDiscovery
        default:
            logger.debug("uncaught action \"\(action)\"")
        }
    }
}

#Preview {
    ContentView()
    #if os(macOS)
        .frame(maxWidth: 410, minHeight: 300)
    #endif
}
