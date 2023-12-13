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
    var missionsManager: UKMissionsManager { UKMissionsManager.shared }

    func snapshot(for configuration: UKSelectedMissionsConfigurationIntent, in context: Context) async -> UKBatteryLevelTimelineEntry {
        logger.debug("requesting snapshot...")
        return .init(date: .now, missionIds: [])
    }

    func timeline(for configuration: UKSelectedMissionsConfigurationIntent, in context: Context) async -> Timeline<UKBatteryLevelTimelineEntry> {
        logger.debug("requesting timeline...")
        let missionIds: [String] = []

        let entries = [UKBatteryLevelTimelineEntry(date: .now, missionIds: missionIds)]
        logger.debug("requesting timeline - returning \(missionIds.count) missionIds and \(entries.count) entries")
        let timeline = Timeline(entries: entries, policy: .never)
        return timeline
    }

    func placeholder(in context: Context) -> UKBatteryLevelTimelineEntry {
        logger.debug("requesting placeholder")
        return .init(date: .now, missionIds: [])
    }

    func recommendations() -> [AppIntentRecommendation<UKSelectedMissionsConfigurationIntent>] {
        logger.debug("requesting recommendations...")
        guard let mission: UKMission = missionsManager.missions.first else {
            logger.debug("no recommendation - there are \(missionsManager.missions.count) missions")
            return []
        }
        logger.debug("found recommendation \(mission.name)")
        let missionEntity: UKMissionEntity = .init(mission: mission)
        let intent: UKSelectedMissionsConfigurationIntent = .init()
        intent.missions = [missionEntity]
        logger.debug("responding with single recommendation \(missionEntity.name)")
        return [.init(intent: intent, description: Text(missionEntity.name))]
    }
}
