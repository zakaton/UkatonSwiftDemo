import AppIntents
import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros
import WidgetKit

@StaticLogger
struct UKBatteryLevelWidgetProvider: AppIntentTimelineProvider {
    typealias Intent = UKSelectedMissionsConfigurationIntent
    typealias Entry = UKBatteryLevelEntry
    var missionsManager: UKMissionsManager { UKMissionsManager.shared }

    func snapshot(for configuration: UKSelectedMissionsConfigurationIntent, in context: Context) async -> UKBatteryLevelEntry {
        let missions = configuration.missions.compactMap {
            missionsManager.mission(for: $0.id)
        }
        logger.debug("requesting snapshot - returning \(missions.count) missions")
        let entry = UKBatteryLevelEntry(date: .now, missions: missions)
        return entry
    }
    
    

    func timeline(for configuration: UKSelectedMissionsConfigurationIntent, in context: Context) async -> Timeline<UKBatteryLevelEntry> {
        let missions = configuration.missions.compactMap {
            missionsManager.mission(for: $0.id)
        }

        let entries = [UKBatteryLevelEntry(date: Date(), missions: missions)]
        logger.debug("requesting snapshot - returning \(missions.count) missions and \(entries.count) entries")
        let timeline = Timeline(entries: entries, policy: .never)
        return timeline
    }

    func placeholder(in context: Context) -> UKBatteryLevelEntry {
        logger.debug("requesting placeholder")
        return UKBatteryLevelEntry(date: Date(), missions: [.none])
    }

    func recommendations() -> [AppIntentRecommendation<UKSelectedMissionsConfigurationIntent>] {
        logger.debug("requesting recommendations")
        guard let mission: UKMission = missionsManager.missions.first else { return [] }

        let missionEntity: UKMissionEntity = .init(mission: mission)
        let intent: UKSelectedMissionsConfigurationIntent = .init()
        intent.missions = [missionEntity]
        logger.debug("responding with single recommendation \(missionEntity.name)")
        return [.init(intent: intent, description: Text(missionEntity.name))]
    }
}
