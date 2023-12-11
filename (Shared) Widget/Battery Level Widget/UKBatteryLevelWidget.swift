import AppIntents
import SwiftUI
import UkatonKit
import WidgetKit

struct UKBatteryLevelWidget: Widget {
    let kind: String = "com.ukaton.demo.battery-level"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: UKSelectedMissionsConfigurationIntent.self, provider: UKBatteryLevelWidgetProvider()) { entry in

            if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
                UKBatteryLevelWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                UKBatteryLevelWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Ukaton Battery Level")
        .description("View battery level of your Ukaton devices")
        #if os(iOS)
            .supportedFamilies([.accessoryCircular, .systemSmall, .systemMedium, .systemLarge])
        #elseif os(macOS)
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        #elseif os(watchOS)
            .supportedFamilies([.accessoryCircular])
        #endif
    }
}

#if os(iOS) || os(watchOS)
    #Preview("accessoryCircular", as: .accessoryCircular) {
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
