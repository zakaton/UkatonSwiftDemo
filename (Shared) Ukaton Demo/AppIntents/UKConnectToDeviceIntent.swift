import AppIntents
import OSLog
import UkatonKit

struct UKConnectToDeviceIntent: AppIntent {
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "UKConnectToDeviceIntent")
    var logger: Logger { Self.logger }

    static var title = LocalizedStringResource("Connect to Device")

    @Parameter(title: "device id")
    var deviceId: String

    @Parameter(title: "connection type")
    var connectionTypeName: String
    var connectionType: UKConnectionType? {
        .init(from: connectionTypeName)
    }

    init() {}

    init(deviceId: String, connectionTypeName: String) {
        self.deviceId = deviceId
        self.connectionTypeName = connectionTypeName
    }

    init(deviceId: String, connectionType: UKConnectionType) {
        self.init(deviceId: deviceId, connectionTypeName: connectionType.name)
    }

    var bluetoothManager: UKBluetoothManager { .shared }

    @MainActor
    func perform() async throws -> some IntentResult {
        logger.debug("connecting to device \(deviceId) via \(connectionType?.name ?? "")")
        if let connectionType,
           let deviceIndex = bluetoothManager.discoveredDevices.firstIndex(where: {
               $0.id?.uuidString == deviceId
           })
        {
            bluetoothManager.discoveredDevices[deviceIndex].connect(type: connectionType)
        }
        else {
            logger.debug("undefined connectonType or no device found...")
        }
        return .result()
    }
}
