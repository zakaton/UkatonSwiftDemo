import AppIntents
import SwiftUI
import UkatonKit
import WidgetKit

struct UKBatteryLevelWidgetProvider: AppIntentTimelineProvider {
    typealias Intent = UKSelectedMissionsConfigurationIntent
    typealias Entry = UKBatteryLevelEntry
    var missionsManager: UKMissionsManager { UKMissionsManager.shared }

    func snapshot(for configuration: UKSelectedMissionsConfigurationIntent, in context: Context) async -> UKBatteryLevelEntry {
        let missions = configuration.missions.compactMap {
            missionsManager.mission(for: $0.id)
        }
        let entry = UKBatteryLevelEntry(date: Date(), missions: missions)
        return entry
    }

    func timeline(for configuration: UKSelectedMissionsConfigurationIntent, in context: Context) async -> Timeline<UKBatteryLevelEntry> {
        let missions = configuration.missions.compactMap {
            missionsManager.mission(for: $0.id)
        }

        let entries = [UKBatteryLevelEntry(date: Date(), missions: missions)]
        let timeline = Timeline(entries: entries, policy: .never)
        return timeline
    }

    func placeholder(in context: Context) -> UKBatteryLevelEntry {
        UKBatteryLevelEntry(date: Date(), missions: [.none])
    }

    func recommendations() -> [AppIntentRecommendation<UKSelectedMissionsConfigurationIntent>] {
        guard let mission: UKMission = missionsManager.missions.first else { return [] }

        let missionEntity: UKMissionEntity = .init(mission: mission)
        let intent: UKSelectedMissionsConfigurationIntent = .init()
        intent.missions = [missionEntity]
        return [.init(intent: intent, description: Text(missionEntity.name))]
    }
}
