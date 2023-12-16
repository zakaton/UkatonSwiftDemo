import OSLog
import UkatonMacros
import WidgetKit

@StaticLogger
struct UKBatteryLevelTimelineEntry: TimelineEntry {
    let date: Date
    private var missionIds: [String]?

    private var devicesInformation: UKDevicesInformation { .shared }

    init(date: Date = .now, missionIds: [String] = []) {
        self.date = date
        self.missionIds = missionIds
    }

    func getInformation(index: Int) -> UKDeviceInformation? {
        if let missionIds, index < missionIds.count {
            return getInformation(id: missionIds[index])
        }
        else {
            return devicesInformation.getInformation(index: index)
        }
    }

    func getInformation(id: String) -> UKDeviceInformation? {
        devicesInformation.getInformation(id: id)
    }
}
