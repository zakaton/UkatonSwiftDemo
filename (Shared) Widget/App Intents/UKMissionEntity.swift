import AppIntents
import UkatonKit

struct UKMissionEntity: AppEntity, Identifiable {
    typealias DefaultQuery = UKMissionEntityQuery
    static var defaultQuery = UKMissionEntityQuery()

    static let none: UKMissionEntity = .init(id: "", name: "", deviceTypeName: "", batteryLevel: 0, isCharging: false)
    var isNone: Bool { id == "" }

    var id: String

    @Property(title: "Name")
    var name: String
    @Property(title: "Device Type")
    var deviceTypeName: String
    @Property(title: "Battery Level")
    var batteryLevel: Int
    @Property(title: "Is Charging")
    var isCharging: Bool

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

    init(id: String, name: String, deviceTypeName: String, batteryLevel: Int, isCharging: Bool) {
        self.id = id
        self.name = name
        self.deviceTypeName = deviceTypeName
        self.batteryLevel = batteryLevel
        self.isCharging = isCharging
    }

    init(information: UKDeviceInformation) {
        self.init(id: information.id, name: information.name, deviceTypeName: information.deviceType.name, batteryLevel: .init(information.batteryLevel), isCharging: information.isCharging)
    }
}
