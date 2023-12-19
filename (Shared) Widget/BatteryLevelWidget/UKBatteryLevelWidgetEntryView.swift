import AppIntents
import SwiftUI
import UkatonKit
import WidgetKit

struct UKBatteryLevelWidgetEntryView: View {
    var entry: UKBatteryLevelWidgetProvider.Entry

    @Environment(\.widgetFamily) var family

    var spacing: CGFloat = 12

    var accessoryCircularBody: some View {
        UKBatteryLevelView()
    }

    var accessoryInlineBody: some View {
        UKBatteryLevelView()
    }

    public static var onlyShowSingleViewForAccessoryRectangular: Bool = is_iOS
    @ViewBuilder
    var accessoryRectangularBody: some View {
        if Self.onlyShowSingleViewForAccessoryRectangular {
            UKBatteryLevelView()
        }
        else {
            HStack(spacing: 8) {
                UKBatteryLevelView(index: 0)
                UKBatteryLevelView(index: 1)
                UKBatteryLevelView(index: 2)
            }
        }
    }

    var accessoryCornerBody: some View {
        UKBatteryLevelView()
    }

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
        HStack(spacing: spacing) {
            ForEach(0 ..< 4) {
                UKBatteryLevelView(index: $0)
            }
        }
    }

    var systemLargeBody: some View {
        VStack(spacing: spacing + 4) {
            ForEach(0 ..< 6) {
                UKBatteryLevelView(index: $0)
                Divider()
            }
        }
    }

    var systemExtraLargeBody: some View {
        VStack(spacing: spacing + 4) {
            ForEach(0 ..< 6) {
                UKBatteryLevelView(index: $0)
                Divider()
            }
        }
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
            case .accessoryInline:
                accessoryCircularBody
            case .accessoryRectangular:
                accessoryRectangularBody
            case .accessoryCorner:
                accessoryCornerBody
            default:
                uncaughtBody
            }
        }

    #elseif os(iOS)
        var body: some View {
            switch family {
            case .accessoryCircular:
                accessoryCircularBody
            case .accessoryInline:
                accessoryInlineBody
            case .accessoryRectangular:
                accessoryRectangularBody
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
