import AppIntents
import SwiftUI
import UkatonKit
import WidgetKit

extension UKBatteryLevelWidget {
    func UKBatteryLevelWidgetConfiguration() -> some WidgetConfiguration {
        StaticConfiguration(kind: "com.ukaton.demo.battery-level", provider: UKBatteryLevelWidgetProvider()) { entry in
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
        .modify {
            #if WATCHOS
            $0.supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner])
            #elseif os(iOS)
            $0.supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular, .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
            #elseif os(macOS)
            $0.supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
            #endif
        }
    }
}
