import Combine
import OSLog
import SafariServices
import UkatonKit
import UkatonMacros

let bluetoothManager: UKBluetoothManager = .shared

@StaticLogger()
class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    func sendMessageToExtension() {
        let messageName = "Hello from App"
        let messageInfo = ["AdditionalInformation": "Goes Here"]
        SFSafariApplication.dispatchMessage(withName: messageName, toExtensionWithIdentifier: Bundle.main.bundleIdentifier!, userInfo: messageInfo) { [self] error in
            guard let error else { return }
            logger.error("Message attempted. Error info: \(String(describing: error), privacy: .public)")
        }
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

        sendMessageToExtension()
    }
}
