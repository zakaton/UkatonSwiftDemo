import AppIntents
import UkatonKit

struct UKMissionEntityQuery: EntityStringQuery {
    @IntentParameterDependency<UKSelectedMissionsConfigurationIntent>(\.$missions)
    var selectedMissions

    func filterOutSelectedMissions(missions: [UKMissionEntity]) -> [UKMissionEntity] {
        missions
    }

    func entities(for identifiers: [UKMissionEntity.ID]) async throws -> [UKMissionEntity] {
        identifiers.compactMap {
            UKMissionsManager.shared.mission(for: $0)
        }.map { .init(mission: $0) }
    }

    func suggestedEntities() async throws -> [UKMissionEntity] {
        let missions = UKMissionsManager.shared.missions.map {
            UKMissionEntity(id: $0.id, name: $0.name, deviceTypeName: $0.deviceType.name)
        }
        return filterOutSelectedMissions(missions: missions)
    }

    func entities(matching string: String) async throws -> [UKMissionEntity] {
        UKMissionsManager.shared.missions.filter {
            $0.name.localizedCaseInsensitiveContains(string)
        }.map { .init(mission: $0) }
    }
}
