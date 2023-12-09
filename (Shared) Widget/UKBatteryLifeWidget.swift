import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    public typealias Entry = UKBatteryLifeEntry

    func placeholder(in context: Context) -> UKBatteryLifeEntry {
        return UKBatteryLifeEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (UKBatteryLifeEntry) -> Void) {
        let entry = UKBatteryLifeEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UKBatteryLifeEntry>) -> Void) {
        let entries = [UKBatteryLifeEntry(date: Date())]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct UKBatteryLifeEntry: TimelineEntry {
    public let date: Date
}

struct PlaceholderView: View {
    var body: some View {
        UKBatteryLifeWidgetEntryView(entry: UKBatteryLifeEntry(date: Date()))
    }
}

struct UKBatteryLifeWidgetEntryView: View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            Text("small")
        default:
            Text("fugg")
        }
    }
}

struct UKBatteryLifeWidget: Widget {
    let kind: String = "UKBatteryLifeWidget"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            UKBatteryLifeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Ukaton Battery Life")
        .description("View battery life of your Ukaton devices")
        #if !os(watchOS)
            .supportedFamilies([.systemSmall])
        #endif
    }
}

#if !os(watchOS)
#Preview(as: .systemSmall) {
    UKBatteryLifeWidget()
} timeline: {
    UKBatteryLifeEntry(date: .now)
}
#endif
