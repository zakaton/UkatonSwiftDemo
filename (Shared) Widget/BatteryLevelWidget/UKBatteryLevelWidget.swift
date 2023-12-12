import AppIntents
import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros
import WidgetKit

@StaticLogger
struct UKBatteryLevelWidget: Widget {
    var body: some WidgetConfiguration {
        UKBatteryLevelWidgetConfiguration()
    }
}

#if os(iOS)
#Preview("accessoryCircular", as: .accessoryCircular) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelEntry(date: .now, missions: [.none])
}

#Preview("accessoryInline", as: .accessoryInline) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelEntry(date: .now, missions: [.none])
}

#Preview("accessoryRectangular", as: .accessoryRectangular) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelEntry(date: .now, missions: [.none])
}
#endif

#if os(iOS) || os(macOS)
#Preview("systemSmall", as: .systemSmall) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelEntry(date: .now, missions: [.none])
}

#Preview("systemMedium", as: .systemMedium) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelEntry(date: .now, missions: [.none])
}

#Preview("systemLarge", as: .systemLarge) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelEntry(date: .now, missions: [.none])
}

#Preview("systemExtraLarge", as: .systemExtraLarge) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelEntry(date: .now, missions: [.none])
}
#endif
