import AppIntents
import OSLog
import UkatonKit

struct UKToggleDeviceScanIntent: AppIntent {
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "UKToggleDeviceScanIntent")
    var logger: Logger { Self.logger }

    static var title = LocalizedStringResource("Toggle Device Scan")

    @MainActor
    func perform() async throws -> some IntentResult {
        logger.debug("toggling device scan")
        UKBluetoothManager.shared.toggleDeviceScan()
        return .result()
    }
}
