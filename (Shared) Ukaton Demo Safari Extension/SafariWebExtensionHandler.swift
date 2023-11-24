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
                            "deviceType": $0.deviceType.rawValue,
                            "rssi": $0.rssi?.intValue ?? 0,
                            "id": $0.id?.uuidString ?? ""
                        ]
                        if $0.isConnectedToWifi, let ipAddress = $0.ipAddress {
                            discoveredDeviceInfo["ipAddress"] = ipAddress
                        }
                        return discoveredDeviceInfo
                    },
                    "timestamp": safariWebExtension.timeSinceUpdatedDiscoveredDevices
                ]]
            }
        default:
            logger.warning("uncaught exception for message type")
            response.userInfo = [SFExtensionMessageKey: ["echo": message]]
        }

        context.completeRequest(returningItems: [response], completionHandler: nil)
    }
}
