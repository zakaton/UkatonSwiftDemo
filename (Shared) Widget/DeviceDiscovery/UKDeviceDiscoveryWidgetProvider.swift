import AppIntents
import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros
import WidgetKit

@StaticLogger
struct UKDeviceDiscoveryWidgetProvider: TimelineProvider {
    typealias Entry = UKDeviceDiscoveryTimelineEntry

    var devicesInformation: UKDevicesInformation { .shared }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = Entry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = Entry()
        let entries = [entry]
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }

    func placeholder(in context: Context) -> Entry {
        logger.debug("requesting placeholder for \(context.family.debugDescription, privacy: .public)")
        return .init(date: .now)
    }
}
