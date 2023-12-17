import AppIntents
import SwiftUI
import UkatonKit
import WidgetKit

extension UKDeviceDiscoveryWidget {
    func UKDeviceDiscoveryWidgetConfiguration() -> some WidgetConfiguration {
        StaticConfiguration(kind: "com.ukaton.demo.device-discovery", provider: UKDeviceDiscoveryWidgetProvider()) { entry in
            if #available(iOS 17.0, macOS 14.0, *) {
                UKDeviceDiscoveryWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                UKDeviceDiscoveryWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Ukaton Device Discovery")
        .description("Scan for Ukaton Devices")
        .modify {
            $0.supportedFamilies([.systemLarge, .systemExtraLarge])
        }
    }
}
