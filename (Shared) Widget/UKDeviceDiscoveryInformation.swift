import Combine
import Foundation
import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros
import WidgetKit

struct UKDiscoveredDeviceInformation: UKAppGroupDeviceMetadata {
    static let none: Self = .init(id: "", name: "", deviceType: .motionModule, isConnectedToWifi: false, ipAddress: nil, connectionType: nil, connectionStatus: .notConnected)
    var isNone: Bool { id == "" }

    let id: String
    let name: String
    let deviceType: UKDeviceType
    let isConnectedToWifi: Bool
    let ipAddress: String?
    let connectionType: UKConnectionType?
    let connectionStatus: UKConnectionStatus
}

typealias UKRawDiscoveredDeviceInformation = [String: String]

@StaticLogger
@Singleton()
class UKDeviceDiscoveryInformation {
    private var bluetoothManager: UKBluetoothManager { .shared }
    private let defaults: UserDefaults = .init(suiteName: "group.com.ukaton.discovered-devices")!

    var ids: [String] {
        defaults.object(forKey: "deviceIds") as? [String] ?? []
    }

    var isScanning: Bool {
        defaults.object(forKey: "isScanning") as? Bool ?? false
    }

    func getInformation(id: String) -> UKDiscoveredDeviceInformation? {
        guard let value = defaults.object(forKey: "device-\(id)") as? UKRawDiscoveredDeviceInformation,
              let name = value["name"],
              let deviceTypeName = value["deviceType"],
              let deviceType: UKDeviceType = .init(from: deviceTypeName),
              let isConnectedToWifiString = value["isConnectedToWifi"],
              let connectionStatusString = value["connectionStatus"],
              let connectionStatus: UKConnectionStatus = .init(from: connectionStatusString)
        else {
            return nil
        }

        let ipAddress = value["ipAddress"]
        let isConnectedToWifi = isConnectedToWifiString == "true"

        var connectionType: UKConnectionType?
        if let connectionTypeString = value["connectionType"] {
            connectionType = .init(from: connectionTypeString)
        }

        return .init(id: id, name: name, deviceType: deviceType, isConnectedToWifi: isConnectedToWifi, ipAddress: ipAddress, connectionType: connectionType, connectionStatus: connectionStatus)
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
                "connectionStatus": discoveredDevice.mission.connectionStatus.name
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

        bluetoothManager.isScanningSubject.sink(receiveValue: { [self] _ in
            let newIsScanning = bluetoothManager.isScanning
            logger.debug("updating isScanning to \(newIsScanning)")
            defaults.setValue(newIsScanning, forKey: "isScanning")
            reloadTimelines()
        }).store(in: &cancellables)

        bluetoothManager.discoveredDevicesSubject
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink(receiveValue: { [self] _ in
                var shouldReloadTimelines = false

                let currentIds = ids
                let newIds = bluetoothManager.discoveredDevices.compactMap { $0.id?.uuidString }
                logger.debug("newIds \(newIds, privacy: .public)")
                let idsToRemove = currentIds.filter { !newIds.contains($0) }
                bluetoothManager.discoveredDevices.forEach { discoveredDevice in
                    shouldReloadTimelines = shouldReloadTimelines || updateDeviceInformation(for: discoveredDevice)
                }

                idsToRemove.forEach {
                    defaults.removeObject(forKey: key(id: $0))
                    let _key = key(id: $0)
                    logger.debug("removed value for key \(_key)")
                }
                shouldReloadTimelines = shouldReloadTimelines || !idsToRemove.isEmpty

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
        logger.debug("reloading timelines")
        WidgetCenter.shared.reloadTimelines(ofKind: "com.ukaton.demo.device-discovery")
    }

    func clear() {
        ids.forEach {
            defaults.removeObject(forKey: "device-\($0)")
        }
        defaults.removeObject(forKey: "deviceIds")
        reloadTimelines()
    }
}
