import AppIntents
import UkatonKit

struct UKViewMission: AppIntent {
    @Parameter(title: "Mission")
    var mission: UKMissionEntity

    static var title: LocalizedStringResource = "View Mission"
    static var openAppWhenRun: Bool = true
    func perform() async throws -> some IntentResult {
        // TODO: - navigate to mission info
        return .result()
    }

    static var parameterSummary: some ParameterSummary {
        Summary("View \(\.$mission)")
    }
}

struct UKSelectedMissionsConfiguration: AppIntent, WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Selected Missions"

    @Parameter(title: "Missions", size: [
        .systemSmall: 3
    ])
    var missions: [UKMissionEntity]

    static var parameterSummary: some ParameterSummary {
        Summary("select missions \(\.$missions)")
    }
}

struct UKMissionEntity: AppEntity, Identifiable {
    typealias DefaultQuery = UKMissionEntityQuery
    static var defaultQuery = UKMissionEntityQuery()

    var id: String

    @Property(title: "Name")
    var name: String
    @Property(title: "Device Type")
    var deviceTypeName: String

    var imageName: String {
        switch deviceTypeName {
        case "motion module":
            "rotate.3d"
        default:
            "shoe"
        }
    }

    var displayRepresentation: DisplayRepresentation {
        .init(title: "\(name)", subtitle: "\(deviceTypeName)", image: .init(systemName: imageName))
    }

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Mission"

    init(id: String, name: String, deviceTypeName: String) {
        self.id = id
        self.name = name
        self.deviceTypeName = deviceTypeName
    }

    init(mission: UKMission) {
        self.init(id: mission.id, name: mission.name, deviceTypeName: mission.deviceType.name)
    }
}

struct UKMissionEntityQuery: EntityStringQuery {
    func entities(for identifiers: [UKMissionEntity.ID]) async throws -> [UKMissionEntity] {
        identifiers.compactMap {
            UKMissionsManager.shared.mission(for: $0)
        }.map { .init(mission: $0) }
    }

    func suggestedEntities() async throws -> [UKMissionEntity] {
        UKMissionsManager.shared.missions.map { .init(id: $0.id, name: $0.name, deviceTypeName: $0.deviceType.name) }
    }

    func entities(matching string: String) async throws -> [UKMissionEntity] {
        UKMissionsManager.shared.missions.filter {
            $0.name.localizedCaseInsensitiveContains(string)
        }.map { .init(mission: $0) }
    }
}
