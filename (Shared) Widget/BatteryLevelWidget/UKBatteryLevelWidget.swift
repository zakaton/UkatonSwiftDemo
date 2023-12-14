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
    UKBatteryLevelTimelineEntry(date: .now)
}

#Preview("accessoryInline", as: .accessoryInline) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelTimelineEntry(date: .now)
}

#Preview("accessoryRectangular", as: .accessoryRectangular) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelTimelineEntry(date: .now)
}
#endif

#if os(iOS) || os(macOS)
#Preview("systemSmall", as: .systemSmall) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelTimelineEntry(date: .now)
}

#Preview("systemMedium", as: .systemMedium) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelTimelineEntry(date: .now)
}

#Preview("systemLarge", as: .systemLarge) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelTimelineEntry(date: .now)
}

#Preview("systemExtraLarge", as: .systemExtraLarge) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelTimelineEntry(date: .now)
}
#endif
