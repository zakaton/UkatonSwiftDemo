import AppIntents
import OSLog
import UkatonKit

struct UKDisconnectFromDeviceIntent: AppIntent {
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "UKDisconnectFromDeviceIntent")
    var logger: Logger { Self.logger }

    static var title = LocalizedStringResource("Disconnect from Device")

    @Parameter(title: "device id")
    var deviceId: String

    init() {}

    init(deviceId: String) {
        self.deviceId = deviceId
    }

    var bluetoothManager: UKBluetoothManager { .shared }

    @MainActor
    func perform() async throws -> some IntentResult {
        logger.debug("disconnecting from device \(deviceId)")
        if let deviceIndex = bluetoothManager.discoveredDevices.firstIndex(where: {
            $0.id?.uuidString == deviceId
        }) {
            bluetoothManager.discoveredDevices[deviceIndex].disconnect()
        }
        else {
            logger.debug("undefined connectonType or no device found...")
        }
        return .result()
    }
}
