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
