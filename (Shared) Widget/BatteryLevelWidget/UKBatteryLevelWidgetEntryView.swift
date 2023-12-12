import AppIntents
import SwiftUI
import UkatonKit
import WidgetKit

struct UKBatteryLevelWidgetEntryView: View {
    var entry: UKBatteryLevelWidgetProvider.Entry

    @Environment(\.widgetFamily) var family

    var spacing: CGFloat = 15

    var missionsManager: UKMissionsManager { .shared }

    var systemSmallBody: some View {
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                UKBatteryLevelView(missionDevice: entry[0])
                UKBatteryLevelView(missionDevice: entry[1])
            }
            HStack(spacing: spacing) {
                UKBatteryLevelView(missionDevice: entry[2])
                UKBatteryLevelView(missionDevice: entry[3])
            }
        }
    }

    var systemMediumBody: some View {
        Text("medium")
            .scaledToFill()
    }

    var systemLargeBody: some View {
        Text("large")
    }

    var systemExtraLargeBody: some View {
        Text("extra large")
    }

    var accessoryCircularBody: some View {
        UKBatteryLevelView(missionDevice: entry[0])
    }

    var uncaughtBody: some View {
        Text("uncaught widget family")
    }

    #if WATCHOS
        var body: some View {
            switch family {
            case .accessoryCircular:
                accessoryCircularBody
            default:
                uncaughtBody
            }
        }

    #elseif os(iOS)
        var body: some View {
            switch family {
            case .accessoryCircular:
                accessoryCircularBody
            case .systemSmall:
                systemSmallBody
            case .systemMedium:
                systemMediumBody
            case .systemLarge:
                systemLargeBody
            default:
                uncaughtBody
            }
        }

    #elseif os(macOS)
        var body: some View {
            switch family {
            case .systemSmall:
                systemSmallBody
            case .systemMedium:
                systemMediumBody
            case .systemLarge:
                systemLargeBody
            case .systemExtraLarge:
                systemExtraLargeBody
            default:
                uncaughtBody
            }
        }
    #endif
}
