import Combine
import Foundation
import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros
import WidgetKit

struct UKDiscoveredDeviceInformation {
    static let none: Self = .init(id: "", name: "", deviceType: .motionModule, isConnectedToWifi: false, ipAddress: nil, isConnected: false, connectionType: nil)
    var isNone: Bool { id == "" }

    let id: String
    let name: String
    let deviceType: UKDeviceType
    let isConnectedToWifi: Bool
    let ipAddress: String?
    let isConnected: Bool
    let connectionType: UKConnectionType?
}

typealias UKRawDiscoveredDeviceInformation = [String: String]

@StaticLogger
@Singleton()
class UKDiscoveredDevicesInformation {
    private var bluetoothManager: UKBluetoothManager { .shared }
    private let defaults: UserDefaults = .init(suiteName: "group.com.ukaton.discovered-devices")!

    var ids: [String] {
        defaults.object(forKey: "deviceIds") as? [String] ?? []
    }

    func getInformation(id: String) -> UKDiscoveredDeviceInformation? {
        guard let value = defaults.object(forKey: "device-\(id)") as? UKRawDiscoveredDeviceInformation,
              let name = value["name"],
              let deviceTypeName = value["deviceType"],
              let deviceType: UKDeviceType = .init(from: deviceTypeName),
              let isConnectedToWifiString = value["isConnectedToWifi"],
              let isConnectedString = value["isConnected"]
        else {
            return nil
        }

        let ipAddress = value["ipAddress"]
        let isConnectedToWifi = isConnectedToWifiString == "true"

        let isConnected = isConnectedString == "true"
        let connectionTypeString = value["ipAddress"]
        var connectionType: UKConnectionType?
        if let connectionTypeString {
            connectionType = .init(from: connectionTypeString)
        }

        return .init(id: id, name: name, deviceType: deviceType, isConnectedToWifi: isConnectedToWifi, ipAddress: ipAddress, isConnected: isConnected, connectionType: connectionType)
    }

    func getInformation(index: Int) -> UKDiscoveredDeviceInformation? {
        guard index < ids.count else { return nil }
        return getInformation(id: ids[index])
    }

    private func key(for discoveredDevice: UKDiscoveredBluetoothDevice) -> String {
        key(id: discoveredDevice.id?.uuidString ?? "")
    }

    private func key(id: String) -> String {
        "device-\(id)"
    }

    private var cancellables: Set<AnyCancellable> = .init()
    private func updateDeviceInformation(for discoveredDevice: UKDiscoveredBluetoothDevice) -> Bool {
        var shouldUpdateDeviceInformation = false
        if let id = discoveredDevice.id?.uuidString, let discoveredDeviceInformation = getInformation(id: id) {
            if discoveredDevice.name != discoveredDeviceInformation.name {
                shouldUpdateDeviceInformation = true
            }
            else if discoveredDevice.deviceType != discoveredDeviceInformation.deviceType {
                shouldUpdateDeviceInformation = true
            }
            else if discoveredDevice.isConnectedToWifi != discoveredDeviceInformation.isConnectedToWifi {
                shouldUpdateDeviceInformation = true
            }
            else if discoveredDevice.ipAddress != discoveredDeviceInformation.ipAddress {
                shouldUpdateDeviceInformation = true
            }
            else if discoveredDevice.mission.isConnected != discoveredDeviceInformation.isConnected {
                shouldUpdateDeviceInformation = true
            }
            else if discoveredDevice.mission.connectionType != discoveredDeviceInformation.connectionType {
                shouldUpdateDeviceInformation = true
            }
        }
        else {
            shouldUpdateDeviceInformation = true
        }

        if shouldUpdateDeviceInformation {
            var rawDiscoveredDeviceInformation: UKRawDiscoveredDeviceInformation = [
                "name": discoveredDevice.name,
                "deviceType": discoveredDevice.deviceType.name,
                "isConnectedToWifi": discoveredDevice.isConnectedToWifi ? "true" : "false",
                "isConnected": discoveredDevice.mission.isConnected ? "true" : "false"
            ]
            if discoveredDevice.isConnectedToWifi, let ipAddress = discoveredDevice.ipAddress {
                rawDiscoveredDeviceInformation["ipAddress"] = ipAddress
            }
            if discoveredDevice.mission.isConnected, let connectionType = discoveredDevice.mission.connectionType {
                rawDiscoveredDeviceInformation["connectionType"] = connectionType.name
            }
            defaults.set(rawDiscoveredDeviceInformation, forKey: key(for: discoveredDevice))
            let _key = key(for: discoveredDevice)
            logger.debug("set value for key \(_key): \(rawDiscoveredDeviceInformation)")
        }
        return shouldUpdateDeviceInformation
    }

    private var isListeningForUpdates: Bool = false
    func listenForUpdates() {
        guard !isListeningForUpdates else { return }
        isListeningForUpdates = true

        bluetoothManager.discoveredDevicesSubject
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink(receiveValue: { [self] _ in
                var shouldReloadTimelines = false

                let currentIds = ids
                var idsToRemove = currentIds
                bluetoothManager.discoveredDevices.forEach { discoveredDevice in
                    idsToRemove = idsToRemove.filter { $0 != discoveredDevice.id?.uuidString }
                    shouldReloadTimelines = shouldReloadTimelines || updateDeviceInformation(for: discoveredDevice)
                }

                idsToRemove.forEach {
                    defaults.removeObject(forKey: key(id: $0))
                    let _key = key(id: $0)
                    logger.debug("removed value for key \(_key)")
                }
                shouldReloadTimelines = shouldReloadTimelines || !idsToRemove.isEmpty

                let newIds = bluetoothManager.discoveredDevices.compactMap { $0.id?.uuidString }
                if currentIds.count != newIds.count || !currentIds.allSatisfy({ newIds.contains($0) }) {
                    shouldReloadTimelines = true
                    defaults.setValue(newIds, forKey: "deviceIds")
                    logger.debug("updating deviceIds to \(newIds)")
                }

                if shouldReloadTimelines {
                    reloadTimelines()
                }
            }).store(in: &cancellables)
    }

    func reloadTimelines() {
        WidgetCenter.shared.reloadTimelines(ofKind: "com.ukaton.demo.device-discovery")
    }

    func clear() {
        ids.forEach {
            defaults.removeObject(forKey: "device-\($0)")
        }
        defaults.removeObject(forKey: "deviceIds")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
