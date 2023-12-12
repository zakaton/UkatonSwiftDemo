import AppIntents
import UkatonKit

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
