import AppIntents
import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros
import WidgetKit

@StaticLogger
struct UKBatteryLevelWidgetProvider: AppIntentTimelineProvider {
    typealias Intent = UKSelectedMissionsConfigurationIntent
    typealias Entry = UKBatteryLevelTimelineEntry

    var devicesInformation: UKDevicesInformation { .shared }

    func snapshot(for configuration: UKSelectedMissionsConfigurationIntent, in context: Context) async -> UKBatteryLevelTimelineEntry {
        logger.debug("requesting snapshot...")
        return .init(date: .now)
    }

    func timeline(for configuration: UKSelectedMissionsConfigurationIntent, in context: Context) async -> Timeline<UKBatteryLevelTimelineEntry> {
        logger.debug("requesting timeline...")
        let entries = [UKBatteryLevelTimelineEntry(date: .now)]
        let timeline = Timeline(entries: entries, policy: .never)
        return timeline
    }

    func placeholder(in context: Context) -> UKBatteryLevelTimelineEntry {
        logger.debug("requesting placeholder")
        return .init(date: .now)
    }

    func recommendations() -> [AppIntentRecommendation<UKSelectedMissionsConfigurationIntent>] {
        logger.debug("requesting recommendations...")
        let intent: UKSelectedMissionsConfigurationIntent = .init()
        let entities = devicesInformation.entities
        if let first = entities.first {
            intent.missions = [first]
            return [.init(intent: intent, description: first.name)]
        }
        return []
    }
}
