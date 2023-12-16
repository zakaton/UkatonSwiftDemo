import AppIntents
import OSLog
import UkatonKit
import UkatonMacros

// @StaticLogger
struct UKViewMissionIntent: AppIntent {
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "UKViewMissionIntent")
    var logger: Logger { Self.logger }

    @Parameter(title: "Mission")
    var mission: UKMissionEntity

    static var title: LocalizedStringResource = "View Mission"
    static var openAppWhenRun: Bool = true
    func perform() async throws -> some IntentResult {
        // TODO: - navigate to mission info
        logger.debug("perform")
        return .result()
    }

    static var parameterSummary: some ParameterSummary {
        Summary("View \(\.$mission)")
    }
}
