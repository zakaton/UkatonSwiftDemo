import AppIntents
import OSLog
import UkatonKit
import UkatonMacros

// @StaticLogger
struct UKMissionEntityQuery: EntityStringQuery {
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "UKMissionEntityQuery")
    var logger: Logger { Self.logger }

    @IntentParameterDependency<UKSelectedMissionsConfigurationIntent>(\.$missions)
    var selectedMissions

    func filterOutSelectedMissions(missions: [UKMissionEntity]) -> [UKMissionEntity] {
        logger.debug("filterOutSelectedMissions \(missions)")
        if let selectedMissions {
            return missions.filter { mission in !selectedMissions.missions.contains { $0.id == mission.id } }
        }
        return missions
    }

    func entities(for identifiers: [UKMissionEntity.ID]) async throws -> [UKMissionEntity] {
        logger.debug("requesting entities for \(identifiers)")
        return identifiers.compactMap {
            UKMissionsManager.shared.mission(for: $0)
        }.map { .init(mission: $0) }
    }

    func suggestedEntities() async throws -> [UKMissionEntity] {
        logger.debug("requesting suggestedEntities")
        let missions = UKMissionsManager.shared.missions.map {
            UKMissionEntity(id: $0.id, name: $0.name, deviceTypeName: $0.deviceType.name)
        }
        return filterOutSelectedMissions(missions: missions)
    }

    func entities(matching string: String) async throws -> [UKMissionEntity] {
        logger.debug("requesting entities matching \(string)")
        return UKMissionsManager.shared.missions.filter {
            $0.name.localizedCaseInsensitiveContains(string)
        }.map { .init(mission: $0) }
    }
}
