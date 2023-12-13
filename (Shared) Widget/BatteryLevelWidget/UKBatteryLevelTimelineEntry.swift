import OSLog
import UkatonKit
import UkatonMacros
import WidgetKit

@StaticLogger
struct UKBatteryLevelTimelineEntry: TimelineEntry {
    public let date: Date
    public let missionIds: [String]
    subscript(index: Int) -> UKMission {
        logger.debug("requesting mission for index \(index)")
        if index < missionIds.count {
            logger.debug("requesting mission for id \(missionIds[index])")
            return UKMissionsManager.shared.mission(for: missionIds[index]) ?? .none
        }
        else {
            return .none
        }
    }
}
