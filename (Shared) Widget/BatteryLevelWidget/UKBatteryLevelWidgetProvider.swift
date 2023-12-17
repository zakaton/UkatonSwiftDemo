import AppIntents
import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros
import WidgetKit

@StaticLogger
struct UKBatteryLevelWidgetProvider: TimelineProvider {
    typealias Entry = UKBatteryLevelTimelineEntry

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

    func placeholder(in context: Context) -> UKBatteryLevelTimelineEntry {
        logger.debug("requesting placeholder for \(context.family.debugDescription, privacy: .public)")
        return .init(date: .now)
    }

//    func timeline(for configuration: UKSelectedMissionsConfigurationIntent, in context: Context) async -> Timeline<Entry> {
//        logger.debug("requesting timeline for \(context.family.debugDescription, privacy: .public)")
//        let entries: [UKBatteryLevelTimelineEntry] = [.init(date: .now, missionIds: configuration.missionIds)]
//        let timeline = Timeline(entries: entries, policy: .never)
//        return timeline
//    }

//    func snapshot(for configuration: UKSelectedMissionsConfigurationIntent, in context: Context) async -> Entry {
//        logger.debug("requesting snapshot for \(context.family.debugDescription, privacy: .public)")
//        return .init(date: .now, missionIds: configuration.missionIds)
//    }

//    func recommendations() -> [AppIntentRecommendation<UKSelectedMissionsConfigurationIntent>] {
//        logger.debug("requesting recommendations...")
//        let intent: UKSelectedMissionsConfigurationIntent = .init()
//        let entities = devicesInformation.entities
//        if let first = entities.first {
//            intent.missions = [first]
//            return [.init(intent: intent, description: first.name)]
//        }
//        return []
//    }
}
