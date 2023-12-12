import AppIntents
import UkatonKit

struct UKSelectedMissionsConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Selected Missions"
    static var description = IntentDescription("Selects the missions to display information for")

    #if WATCHOS
    @Parameter(title: "Missions", size: [
        .accessoryCircular: 1
    ])
    var missions: [UKMissionEntity]
    #elseif os(iOS)
    @Parameter(title: "Missions", size: [
        .accessoryCircular: 1,
        .systemSmall: 4,
        .systemMedium: 4
    ])
    var missions: [UKMissionEntity]
    #elseif os(macOS)
    @Parameter(title: "Missions", size: [
        .systemSmall: 4
    ])
    var missions: [UKMissionEntity]
    #endif

    init(missions: [UKMissionEntity]) {
        self.missions = missions
    }

    init() {
        self.missions = []
    }

    static var parameterSummary: some ParameterSummary {
        Summary("select missions \(\.$missions)")
    }

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
