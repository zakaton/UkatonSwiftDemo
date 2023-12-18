import Combine
import Foundation
import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros
import WidgetKit

struct UKDeviceInformation: UKAppGroupDeviceMetadata {
    static let none: Self = .init(id: "", name: "", deviceType: .motionModule, batteryLevel: 0, isCharging: false, isConnectedToWifi: false, ipAddress: nil, connectionType: nil, connectionStatus: .notConnected)
    var isNone: Bool { id == "" }

    let id: String
    let name: String
    let deviceType: UKDeviceType
    let batteryLevel: UKBatteryLevel
    let isCharging: Bool
    let isConnectedToWifi: Bool
    let ipAddress: String?
    let connectionType: UKConnectionType?
    let connectionStatus: UKConnectionStatus
}

typealias UKRawDeviceInformation = [String: String]

@StaticLogger
@Singleton()
class UKDevicesInformation {
    private var missionsManager: UKMissionsManager { .shared }
    private let defaults: UserDefaults = .init(suiteName: "group.com.ukaton.devices")!

    var ids: [String] {
        defaults.object(forKey: "deviceIds") as? [String] ?? []
    }

    func getInformation(id: String) -> UKDeviceInformation? {
        guard let value = defaults.object(forKey: "device-\(id)") as? UKRawDeviceInformation,
              let name = value["name"],
              let deviceTypeName = value["deviceType"],
              let deviceType: UKDeviceType = .init(from: deviceTypeName),
              let batteryLevelString = value["batteryLevel"],
              let batteryLevel: UKBatteryLevel = .init(batteryLevelString),
              let isChargingString = value["isCharging"],
              let isConnectedToWifiString = value["isConnectedToWifi"],
              let connectionStatusString = value["connectionStatus"],
              let connectionStatus: UKConnectionStatus = .init(from: connectionStatusString)
        else {
            return nil
        }

        let isCharging = isChargingString == "true"

        let ipAddress = value["ipAddress"]
        let isConnectedToWifi = isConnectedToWifiString == "true"

        var connectionType: UKConnectionType?
        if let connectionTypeString = value["connectionType"] {
            connectionType = .init(from: connectionTypeString)
        }

        return .init(id: id, name: name, deviceType: deviceType, batteryLevel: batteryLevel, isCharging: isCharging, isConnectedToWifi: isConnectedToWifi, ipAddress: ipAddress, connectionType: connectionType, connectionStatus: connectionStatus)
    }

    func getInformation(index: Int) -> UKDeviceInformation? {
        guard index < ids.count else { return nil }
        return getInformation(id: ids[index])
    }

    private func key(for mission: UKMission) -> String {
        "device-\(mission.id)"
    }

    private var cancellables: Set<AnyCancellable> = .init()
    private var missionsCancellables: [String: Set<AnyCancellable>] = .init()
    private func updateDeviceInformation(for mission: UKMission) {
        var rawDeviceInformation: UKRawDeviceInformation = [
            "name": mission.name,
            "deviceType": mission.deviceType.name,
            "batteryLevel": .init(mission.batteryLevel),
            "isCharging": mission.isCharging ? "true" : "false",
            "isConnectedToWifi": mission.isConnectedToWifi ? "true" : "false",
            "connectionStatus": mission.connectionStatus.name
        ]
        if mission.isConnectedToWifi, let ipAddress = mission.ipAddress {
            rawDeviceInformation["ipAddress"] = ipAddress
        }
        if mission.isConnected, let connectionType = mission.connectionType {
            rawDeviceInformation["connectionType"] = connectionType.name
        }
        defaults.set(rawDeviceInformation, forKey: key(for: mission))
        let _key = key(for: mission)
        logger.debug("set value for key \(_key): \(rawDeviceInformation)")
    }

    private var isListeningForUpdates: Bool = false
    func listenForUpdates() {
        guard !isListeningForUpdates else { return }
        isListeningForUpdates = true

        // logger.debug("listening for UKDevicesInformation updates")
        missionsManager.missionAddedSubject.sink(receiveValue: { [self] mission in
            updateDeviceInformation(for: mission)

            if missionsCancellables[mission.id] == nil {
                missionsCancellables[mission.id] = .init()
            }

            mission.batteryLevelSubject.dropFirst().sink(receiveValue: { [self, mission] _ in
                updateDeviceInformation(for: mission)
                reloadTimelines()
            }).store(in: &missionsCancellables[mission.id]!)

            let newIds = missionsManager.missions.map { $0.id }
            defaults.setValue(newIds, forKey: "deviceIds")
            logger.debug("mission added - updating deviceIds to \(newIds)")

            reloadTimelines()
        }).store(in: &cancellables)
        missionsManager.missionRemovedSubject.sink(receiveValue: { [self] mission in
            defaults.removeObject(forKey: key(for: mission))
            let _key = key(for: mission)
            logger.debug("removed value for key \(_key)")

            let newIds = missionsManager.missions.map { $0.id }
            defaults.set(newIds, forKey: "deviceIds")
            logger.debug("mission removed - updating deviceIds to \(newIds)")

            missionsCancellables.removeValue(forKey: mission.id)

            reloadTimelines()
        }).store(in: &cancellables)
    }

    func reloadTimelines() {
        WidgetCenter.shared.reloadTimelines(ofKind: "com.ukaton.demo.battery-level")
    }

    func clear() {
        ids.forEach {
            defaults.removeObject(forKey: "device-\($0)")
        }
        defaults.removeObject(forKey: "deviceIds")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
