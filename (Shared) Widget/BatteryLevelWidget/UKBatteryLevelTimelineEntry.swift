import OSLog
import UkatonMacros
import WidgetKit

@StaticLogger
struct UKBatteryLevelTimelineEntry: TimelineEntry {
    var devicesInformation: UKDevicesInformation { .shared }

    public let date: Date
    subscript(id: String) -> UKMissionEntity {
        logger.debug("requesting mission for id \(id)")
        return devicesInformation.information(id: id) ?? .none
    }
}
