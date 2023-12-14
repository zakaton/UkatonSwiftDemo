import AppIntents
import SwiftUI
import UkatonKit
import WidgetKit

struct UKBatteryLevelWidgetEntryView: View {
    var entry: UKBatteryLevelWidgetProvider.Entry

    @Environment(\.widgetFamily) var family

    var devicesInformation: UKDevicesInformation { .shared }

    var spacing: CGFloat = 15

    var systemSmallBody: some View {
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                UKBatteryLevelView(index: 0)
                UKBatteryLevelView(index: 1)
            }
            HStack(spacing: spacing) {
                UKBatteryLevelView(index: 2)
                UKBatteryLevelView(index: 3)
            }
        }
    }

    var systemMediumBody: some View {
        Text("medium")
            .unredacted()
    }

    var systemLargeBody: some View {
        Text("large")
            .unredacted()
    }

    var systemExtraLargeBody: some View {
        Text("extra large")
            .unredacted()
    }

    var accessoryCircularBody: some View {
        UKBatteryLevelView()
    }

    var uncaughtBody: some View {
        Text("uncaught widget family")
            .unredacted()
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
