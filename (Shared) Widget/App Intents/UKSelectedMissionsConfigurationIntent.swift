import AppIntents
import UkatonKit

struct UKSelectedMissionsConfigurationIntent: AppIntent, WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Selected Missions"

    // @Parameter(title: "Missions")
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

    static var parameterSummary: some ParameterSummary {
        Summary("select missions \(\.$missions)")
    }
}
