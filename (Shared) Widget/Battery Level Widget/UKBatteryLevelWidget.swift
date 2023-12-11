import AppIntents
import SwiftUI
import UkatonKit
import WidgetKit

struct UKBatteryLevelWidgetProvider: AppIntentTimelineProvider {
    typealias Intent = UKSelectedMissionsConfiguration
    public typealias Entry = UKBatteryLevelEntry
    var missionsManager: UKMissionsManager { UKMissionsManager.shared }

    func snapshot(for configuration: UKSelectedMissionsConfiguration, in context: Context) async -> UKBatteryLevelEntry {
        let missions = configuration.missions.compactMap {
            missionsManager.mission(for: $0.id)
        }
        let entry = UKBatteryLevelEntry(date: Date(), missions: missions)
        return entry
    }

    func timeline(for configuration: UKSelectedMissionsConfiguration, in context: Context) async -> Timeline<UKBatteryLevelEntry> {
        let missions = configuration.missions.compactMap {
            missionsManager.mission(for: $0.id)
        }

        let entries = [UKBatteryLevelEntry(date: Date(), missions: missions)]
        let timeline = Timeline(entries: entries, policy: .never)
        return timeline
    }

    func placeholder(in context: Context) -> UKBatteryLevelEntry {
        return UKBatteryLevelEntry(date: Date(), missions: [.none])
    }
}

struct UKBatteryLevelEntry: TimelineEntry {
    public let date: Date
    public let missions: [UKMission]
}

struct UKBatteryLevelWidgetEntryPlaceholderView: View {
    var body: some View {
        UKBatteryLevelWidgetEntryView(entry: UKBatteryLevelEntry(date: .now, missions: [.none]))
    }
}

struct UKBatteryLevelView: View {
    var missionDevice: UKMission
    var batteryLevel: UKBatteryLevel {
        missionDevice.batteryLevel
    }

    var batteryLevelProgress: Double {
        guard !missionDevice.isNone else { return .zero }
        return .init(batteryLevel) / 100
    }

    var isCharging: Bool {
        missionDevice.isCharging
    }

    var deviceType: UKDeviceType {
        missionDevice.deviceType
    }

    @Environment(\.widgetFamily) var family

    var imageName: String? {
        guard !missionDevice.isNone else { return nil }

        return switch deviceType {
        case .leftInsole, .rightInsole:
            "shoe.fill"
        case .motionModule:
            "rotate.3d.fill"
        }
    }

    private var imageScale: Image.Scale {
        switch family {
        case .accessoryCircular:
            .large
        default:
            .medium
        }
    }

    var color: Color {
        guard !missionDevice.isNone else { return .gray }

        return switch batteryLevel {
        case 60 ... 100:
            .green
        case 10 ... 60:
            .orange
        case 0 ... 10:
            .red
        default:
            .red
        }
    }

    var body: some View {
        ZStack {
            if let imageName {
                Image(systemName: imageName)
                    .imageScale(imageScale)
                    .modify {
                        if deviceType == .leftInsole {
                            $0.scaleEffect(x: -1)
                        }
                    }
            }

            ProgressView(value: .init(batteryLevelProgress))
                .progressViewStyle(.circular)
                .tint(color)
            if isCharging {
                VStack {
                    Image(systemName: "bolt.fill")
                        .imageScale(.medium)
                        .offset(y: -5)
                    Spacer()
                }
            }
        }
    }
}

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

struct UKBatteryLevelWidget: Widget {
    let kind: String = "com.ukaton.demo.battery-level"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: UKSelectedMissionsConfiguration.self, provider: UKBatteryLevelWidgetProvider()) { entry in

            if #available(iOS 17.0, *) {
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
