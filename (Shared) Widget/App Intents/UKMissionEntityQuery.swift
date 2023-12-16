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

    var devicesInformation: UKDevicesInformation { .shared }

    func entities(for identifiers: [UKMissionEntity.ID]) async throws -> [UKMissionEntity] {
        logger.debug("requesting entities for \(identifiers)")
        return devicesInformation.entities
    }

    func suggestedEntities() async throws -> [UKMissionEntity] {
        logger.debug("requesting suggestedEntities")
        let missions = devicesInformation.entities
        logger.debug("\(missions)")
        return filterOutSelectedMissions(missions: missions)
    }

    func entities(matching string: String) async throws -> [UKMissionEntity] {
        logger.debug("requesting entities matching \(string)")
        return devicesInformation.entities.filter {
            $0.name.localizedStandardContains(string)
        }
    }

    func filterOutSelectedMissions(missions: [UKMissionEntity]) -> [UKMissionEntity] {
        logger.debug("filterOutSelectedMissions \(missions)")
        if let selectedMissions {
            return missions.filter { mission in !selectedMissions.missions.contains { $0.id == mission.id } }
        }
        return missions
    }
}
