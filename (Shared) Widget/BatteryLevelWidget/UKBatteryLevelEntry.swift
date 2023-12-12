import UkatonKit
import WidgetKit

struct UKBatteryLevelEntry: TimelineEntry {
    public let date: Date
    public let missions: [UKMission]
    subscript(index: Int) -> UKMission {
        index < missions.count ? missions[index] : .none
    }
}
