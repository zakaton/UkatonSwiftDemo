import AppIntents
import SwiftUI
import UkatonKit
import WidgetKit

struct UKBatteryLevelWidgetEntryView: View {
    var entry: UKBatteryLevelWidgetProvider.Entry

    @Environment(\.widgetFamily) var family

    var spacing: CGFloat = 15

    var missionsManager: UKMissionsManager { .shared }

    var body: some View {
        switch family {
        #if os(iOS) || os(watchOS)
            case .accessoryCircular:
                UKBatteryLevelView(missionDevice: .none)
        #endif
        #if os(iOS) || os(macOS)
            case .systemSmall:
                VStack(spacing: spacing) {
                    HStack(spacing: spacing) {
                        UKBatteryLevelView(missionDevice: .none)
                        UKBatteryLevelView(missionDevice: .none)
                    }
                    HStack(spacing: spacing) {
                        UKBatteryLevelView(missionDevice: .none)
                        UKBatteryLevelView(missionDevice: .none)
                    }
                }
        #endif
        case .systemMedium:
            Text("medium")
        case .systemLarge:
            Text("large")
        case .systemExtraLarge:
            Text("extra large")
        default:
            Text("uncaught widget family")
        }
    }
}
