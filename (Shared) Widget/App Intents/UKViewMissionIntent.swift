import AppIntents
import UkatonKit

struct UKViewMissionIntent: AppIntent {
    @Parameter(title: "Mission")
    var mission: UKMissionEntity

    static var title: LocalizedStringResource = "View Mission"
    static var openAppWhenRun: Bool = true
    func perform() async throws -> some IntentResult {
        // TODO: - navigate to mission info
        return .result()
    }

    static var parameterSummary: some ParameterSummary {
        Summary("View \(\.$mission)")
    }
}
