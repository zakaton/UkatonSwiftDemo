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
    UKBatteryLevelTimelineEntry(date: .now, missionIds: [])
}

#Preview("accessoryInline", as: .accessoryInline) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelTimelineEntry(date: .now, missionIds: [])
}

#Preview("accessoryRectangular", as: .accessoryRectangular) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelTimelineEntry(date: .now, missionIds: [])
}
#endif

#if os(iOS) || os(macOS)
#Preview("systemSmall", as: .systemSmall) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelTimelineEntry(date: .now, missionIds: [])
}

#Preview("systemMedium", as: .systemMedium) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelTimelineEntry(date: .now, missionIds: [])
}

#Preview("systemLarge", as: .systemLarge) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelTimelineEntry(date: .now, missionIds: [])
}

#Preview("systemExtraLarge", as: .systemExtraLarge) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelTimelineEntry(date: .now, missionIds: [])
}
#endif
