//
//  test.swift
//  test
//
//  Created by Zack Qattan on 12/9/23.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), emoji: "😀")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct testEntryView: View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            VStack {
                Text("Time:")
                Text(entry.date, style: .time)

                Text("Emoji:")
                Text(entry.emoji)
            }
        default:
            Text("default")
        }
    }
}

struct test: Widget {
    let kind: String = "test"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                testEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                testEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    test()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
    SimpleEntry(date: .now, emoji: "🤩")
}
