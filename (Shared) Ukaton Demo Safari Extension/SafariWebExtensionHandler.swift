import Combine
import OSLog
import SafariServices
import UkatonKit
import UkatonMacros

@StaticLogger()
class SafariWebExtension {
    static let shared = SafariWebExtension()

    var bluetoothManager: UKBluetoothManager { .shared }
    var cancellables: Set<AnyCancellable> = .init()

    private let now: Date = .now
    private var lastTimeUpdatedDiscoveredDevices: Date = .now
    var timeSinceUpdatedDiscoveredDevices: TimeInterval {
        lastTimeUpdatedDiscoveredDevices.timeIntervalSince(now)
    }

    private var lastTimeUpdatedIsScanning: Date = .now
    var timeSinceUpdatedIsScanning: TimeInterval {
        lastTimeUpdatedIsScanning.timeIntervalSince(now)
    }

    init() {
        bluetoothManager.discoveredDevicesSubject
            .sink(receiveValue: { [self] _ in
                lastTimeUpdatedDiscoveredDevices = .now
            }).store(in: &cancellables)

        bluetoothManager.isScanningSubject
            .sink(receiveValue: { [self] _ in
                lastTimeUpdatedIsScanning = .now
            }).store(in: &cancellables)
    }
}

@StaticLogger()
class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    var bluetoothManager: UKBluetoothManager { .shared }
    let safariWebExtension: SafariWebExtension = .shared

    func getDiscoveredDeviceIndex(id: String) -> Int? {
        bluetoothManager.discoveredDevices.firstIndex(where: { $0.id?.uuidString == id })
    }

    func getMission(id: String) -> UKMission? {
        guard let discoveredDevice = bluetoothManager.discoveredDevices.first(where: { $0.id?.uuidString == id }) else { return nil }
        return discoveredDevice.mission
    }

    func beginRequest(with context: NSExtensionContext) {
        guard let item = context.inputItems.first as? NSExtensionItem,
              let userInfo = item.userInfo as? [String: Any],
              let messageData = userInfo[SFExtensionMessageKey]
        else {
            context.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }

        guard let message = messageData as? [String: Any] else {
            logger.error("invalid message")
            return
        }

        logger.debug("\(String(describing: message), privacy: .public)")

        let response = NSExtensionItem()

        let timestamp = message["timestamp"] as? Double

        switch message["type"] as? String {
        case "toggleScan":
            logger.debug("toggle scan")
            bluetoothManager.toggleDeviceScan()
            response.userInfo = [SFExtensionMessageKey: [
                "isScanning": bluetoothManager.isScanning,
                "timestamp": safariWebExtension.timeSinceUpdatedIsScanning
            ]]
        case "stopScan":
            logger.debug("stop scan")
            bluetoothManager.stopScanningForDevices()
            response.userInfo = [SFExtensionMessageKey: [
                "isScanning": bluetoothManager.isScanning,
                "timestamp": safariWebExtension.timeSinceUpdatedIsScanning
            ]]
        case "requestIsScanning":
            logger.debug("request isScanning")
            if timestamp != safariWebExtension.timeSinceUpdatedIsScanning {
                response.userInfo = [SFExtensionMessageKey: [
                    "isScanning": bluetoothManager.isScanning,
                    "timestamp": safariWebExtension.timeSinceUpdatedIsScanning
                ]]
            }
        case "requestDiscoveredDevices":
            logger.debug("request discovered devices")
            if timestamp != safariWebExtension.timeSinceUpdatedDiscoveredDevices {
                response.userInfo = [SFExtensionMessageKey: [
                    "discoveredDevices": bluetoothManager.discoveredDevices.map {
                        var discoveredDeviceInfo: [String: Any] = [
                            "name": $0.name,
                            "deviceType": $0.deviceType.name,
                            "rssi": $0.rssi?.intValue ?? 0,
                            "id": $0.id?.uuidString ?? "",
                            "timestampDifference": $0.timestampDifference_ms,
                            "connectionStatus": $0.mission.connectionStatus.name
                        ]
                        if $0.isConnectedToWifi, let ipAddress = $0.ipAddress {
                            discoveredDeviceInfo["ipAddress"] = ipAddress
                        }
                        if let connectionType = $0.mission.connectionType {
                            discoveredDeviceInfo["connectionType"] = connectionType.name
                        }
                        return discoveredDeviceInfo
                    },
                    "timestamp": safariWebExtension.timeSinceUpdatedDiscoveredDevices
                ]]
            }
        case "connect":
            if let id = message["id"] as? String,
               let discoveredDeviceIndex = getDiscoveredDeviceIndex(id: id),
               let connectionTypeString = message["connectionType"] as? String,
               let connectionType: UKConnectionType = .init(from: connectionTypeString)
            {
                bluetoothManager.discoveredDevices[discoveredDeviceIndex].connect(type: connectionType)
            }
            else {
                logger.error("no discoveredDevice found in connect message")
            }
        case "requestConnectionStatus":
            if let id = message["id"] as? String,
               let mission = getMission(id: id)
            {
                var message: [String: Any] = [
                    "connectionStatus": mission.connectionStatus.name
                ]
                if let connectionType = mission.connectionType {
                    message["connectionType"] = connectionType.name
                }

                response.userInfo = [SFExtensionMessageKey: message]
            }
            else {
                logger.error("no mission found in isConnected message")
            }
        case "disconnect":
            if let id = message["id"] as? String,
               let discoveredDeviceIndex = getDiscoveredDeviceIndex(id: id)
            {
                bluetoothManager.discoveredDevices[discoveredDeviceIndex].disconnect()
            }
            else {
                logger.error("no discoveredDevice found in disconnect message")
            }
        default:
            logger.warning("uncaught exception for message type")
            response.userInfo = [SFExtensionMessageKey: ["echo": message]]
        }

        context.completeRequest(returningItems: [response], completionHandler: nil)
    }
}
