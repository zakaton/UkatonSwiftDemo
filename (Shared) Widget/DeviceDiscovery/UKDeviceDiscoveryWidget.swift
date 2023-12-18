import AppIntents
import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros
import WidgetKit

@StaticLogger
struct UKDeviceDiscoveryWidget: Widget {
    var body: some WidgetConfiguration {
        UKDeviceDiscoveryWidgetConfiguration()
    }
}

#if os(iOS) || os(macOS)
#Preview("systemLarge", as: .systemLarge) {
    UKDeviceDiscoveryWidget()
} timeline: {
    UKDeviceDiscoveryTimelineEntry(date: .now)
}
#endif
