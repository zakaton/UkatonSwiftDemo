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

    init() {
        bluetoothManager.discoveredDevicesSubject
            .sink(receiveValue: { _ in
                // TODO: - fill
            }).store(in: &cancellables)

        bluetoothManager.isScanningSubject
            .sink(receiveValue: { isScanning in
                #if os(macOS)
                self.sendMessageToExtension(
                    withName: "isScanning",
                    userInfo: ["isScanning": isScanning]
                )
                #endif
            }).store(in: &cancellables)
    }

    func sendMessageToExtension(withName messageName: String, userInfo messageInfo: [String: Any]) {
        #if os(macOS)
        SFSafariApplication.dispatchMessage(withName: messageName, toExtensionWithIdentifier: Bundle.main.bundleIdentifier!, userInfo: messageInfo) { [self] error in
            guard let error else { return }
            logger.error("Message attempted. Error info: \(String(describing: error), privacy: .public)")
        }
        #endif
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

        let response = NSExtensionItem()

        logger.debug("\(String(describing: message), privacy: .public)")

        switch message["type"] {
        case "toggleScan" as String:
            logger.debug("toggle scan")
            bluetoothManager.toggleDeviceScan()
            response.userInfo = [SFExtensionMessageKey: ["isScanning": bluetoothManager.isScanning]]
        default:
            logger.warning("uncaught exception for message type")
            response.userInfo = [SFExtensionMessageKey: ["echo": message]]
        }

        context.completeRequest(returningItems: [response], completionHandler: nil)
    }
}
