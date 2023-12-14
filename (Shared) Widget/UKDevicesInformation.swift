import Combine
import Foundation
import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros

@StaticLogger
@Singleton()
class UKDevicesInformation {
    private var missionsManager: UKMissionsManager { .shared }
    private let defaults: UserDefaults = .init(suiteName: "com.ukaton.devices")!

    var ids: [String] {
        defaults.object(forKey: "deviceIds") as? [String] ?? []
    }

    typealias UKDeviceInformation = [String: String]
    func information(id: String) -> UKMissionEntity? {
        if let value = defaults.object(forKey: "device-\(id)") as? UKDeviceInformation,
           let name = value["name"],
           let deviceTypeName = value["deviceType"],
           let batteryLevelString = value["batteryLevel"],
           let batteryLevel: Int = .init(batteryLevelString),
           let isChargingString = value["isCharging"]
        {
            let isCharging = isChargingString == "true"
            return .init(id: id, name: name, deviceTypeName: deviceTypeName, batteryLevel: batteryLevel, isCharging: isCharging)
        }
        return nil
    }

    func information(index: Int) -> UKMissionEntity? {
        if index < ids.count {
            return information(id: ids[index])
        }
        return nil
    }

    private func key(for mission: UKMission) -> String {
        "device-\(mission.id)"
    }

    private var cancellables: Set<AnyCancellable> = .init()
    private var missionsCancellables: [String: Set<AnyCancellable>] = .init()
    private func updateDeviceInformation(for mission: UKMission) {
        let deviceInformation: UKDeviceInformation = [
            "name": mission.name,
            "deviceType": mission.deviceType.name,
            "batteryLevel": .init(mission.batteryLevel),
            "isCharging": mission.isCharging ? "true" : "false"
        ]
        defaults.set(deviceInformation, forKey: key(for: mission))
        let _key = key(for: mission)
        logger.debug("set value for key \(_key): \(deviceInformation)")
    }

    func listenForUpdates() {
        missionsManager.missionAddedSubject.sink(receiveValue: { [self] mission in
            updateDeviceInformation(for: mission)

            if missionsCancellables[mission.id] == nil {
                missionsCancellables[mission.id] = .init()
            }

            mission.batteryLevelSubject.dropFirst().sink(receiveValue: { [self, mission] _ in
                updateDeviceInformation(for: mission)
            }).store(in: &missionsCancellables[mission.id]!)

            let newIds = missionsManager.missions.map { $0.id }
            defaults.setValue(newIds, forKey: "deviceIds")
            logger.debug("mission added - updating deviceIds to \(newIds)")
        }).store(in: &cancellables)
        missionsManager.missionRemovedSubject.sink(receiveValue: { [self] mission in
            defaults.removeObject(forKey: key(for: mission))
            let _key = key(for: mission)
            logger.debug("removed value for key \(_key)")

            let newIds = missionsManager.missions.map { $0.id }
            defaults.set(newIds, forKey: "deviceIds")
            logger.debug("mission removed - updating deviceIds to \(newIds)")

            missionsCancellables.removeValue(forKey: mission.id)
        }).store(in: &cancellables)
    }

    var entities: [UKMissionEntity] {
        ids.compactMap { information(id: $0) }
    }
}
