import SwiftUI
#if !os(visionOS)
import WidgetKit
#endif

@main
struct UkatonDemoApp: App {
    init() {
        #if !os(visionOS) && !os(tvOS)
        UKDevicesInformation.shared.clear()
        UKDeviceDiscoveryInformation.shared.clear()
        #endif
    }

    @Environment(\.scenePhase) private var phase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
