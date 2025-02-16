import SwiftUI
import WidgetKit

@main
struct UKWidgetBundle: WidgetBundle {
    var body: some Widget {
        UKBatteryLevelWidget()
        #if !os(watchOS)
        UKDeviceDiscoveryWidget()
        #endif
    }
}
