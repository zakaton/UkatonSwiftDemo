import SwiftUI
import UkatonKit
import WidgetKit

extension WidgetFamily: EnvironmentKey {
    public static var defaultValue: WidgetFamily = .systemMedium
}

extension EnvironmentValues {
    var widgetFamily: WidgetFamily {
        get { self[WidgetFamily.self] }
        set { self[WidgetFamily.self] = newValue }
    }
}

struct UKBatteryLevelWidgetProvider: TimelineProvider {
    public typealias Entry = UKBatteryLevelEntry

    func placeholder(in context: Context) -> UKBatteryLevelEntry {
        return UKBatteryLevelEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (UKBatteryLevelEntry) -> Void) {
        let entry = UKBatteryLevelEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UKBatteryLevelEntry>) -> Void) {
        let entries = [UKBatteryLevelEntry(date: Date())]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct UKBatteryLevelEntry: TimelineEntry {
    public let date: Date
}

struct UKBatteryLevelWidgetEntryPlaceholderView: View {
    var body: some View {
        UKBatteryLevelWidgetEntryView(entry: UKBatteryLevelEntry(date: Date()))
    }
}

struct UKBatteryLevelView: View {
    var batteryLevel: UKBatteryLevel
    var isCharging: Bool = false
    var deviceType: UKDeviceType = .motionModule

    var imageName: String {
        switch deviceType {
        case .leftInsole, .rightInsole:
            "shoe.fill"
        case .motionModule:
            "rotate.3d.fill"
        }
    }

    var color: Color {
        switch batteryLevel {
        case 70 ... 100:
            .green
        case 25 ... 70:
            .orange
        case 0 ... 25:
            .red
        default:
            .red
        }
    }

    var body: some View {
        ZStack {
            Image(systemName: imageName)
                .imageScale(.medium)
                .modify {
                    if deviceType == .leftInsole {
                        $0.scaleEffect(x: -1)
                    }
                }

            ProgressView(value: .init(Double(batteryLevel) / 100.0))
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

    var body: some View {
        switch family {
        #if os(iOS) || os(watchOS)
            case .accessoryCircular:
                UKBatteryLevelView(batteryLevel: 100)
        #endif
        case .systemSmall:
            Text("small")
        default:
            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    UKBatteryLevelView(batteryLevel: 100)
                    UKBatteryLevelView(batteryLevel: 60)
                }
                HStack(spacing: spacing) {
                    UKBatteryLevelView(batteryLevel: 40)
                    UKBatteryLevelView(batteryLevel: 20)
                }
            }
        }
    }
}

struct UKBatteryLevelWidget: Widget {
    let kind: String = "UKBatteryLevelWidget"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UKBatteryLevelWidgetProvider()) { entry in

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
        #if os(iOS) || os(watchOS)
            .supportedFamilies([.systemSmall, .accessoryCircular])
        #else
            .supportedFamilies([.systemSmall])
        #endif
    }
}

#Preview(as: .systemSmall) {
    UKBatteryLevelWidget()

} timeline: {
    UKBatteryLevelEntry(date: .now)
}

#if os(iOS) || os(watchOS)
    #Preview(as: .accessoryCircular) {
        UKBatteryLevelWidget()
    } timeline: {
        UKBatteryLevelEntry(date: .now)
    }
#endif
