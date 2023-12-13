import AppIntents
import SwiftUI
import UkatonKit
import WidgetKit

struct UKBatteryLevelWidget: Widget {
    var body: some WidgetConfiguration {
        UKBatteryLevelWidgetConfiguration()
    }
}

#if WATCHOS
#Preview("accessoryCircular", as: .accessoryCircular) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelTimelineEntry(date: .now, missions: [.none])
}

#Preview("accessoryInline", as: .accessoryInline) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelTimelineEntry(date: .now, missions: [.none])
}

#Preview("accessoryRectangular", as: .accessoryRectangular) {
    UKBatteryLevelWidget()
} timeline: {
    UKBatteryLevelTimelineEntry(date: .now, missions: [.none])
}
#endif
