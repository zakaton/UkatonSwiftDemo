import AppIntents
import SwiftUI
import UkatonKit
import WidgetKit

struct UKBatteryLevelView: View {
    init(index: Int) {
        mission = UKDevicesInformation.shared.information(index: index) ?? .none
    }

    init() {
        mission = .none
    }

    var mission: UKMissionEntity
    var batteryLevel: UKBatteryLevel {
        .init(mission.batteryLevel)
    }

    var batteryLevelProgress: Double {
        guard !mission.isNone else { return .zero }
        return .init(batteryLevel) / 100
    }

    var isCharging: Bool {
        mission.isCharging
    }

    var deviceTypeName: String {
        mission.deviceTypeName
    }

    @Environment(\.widgetFamily) var family

    var imageName: String? {
        guard !mission.isNone else { return nil }

        return switch deviceTypeName {
        case "left insole", "right insole":
            "shoe.fill"
        default:
            "rotate.3d.fill"
        }
    }

    private var imageScale: Image.Scale {
        switch family {
        #if !os(macOS)
            case .accessoryCircular:
                .large
        #endif
        default:
            .medium
        }
    }

    var color: Color {
        guard !mission.isNone else { return .gray }

        return switch batteryLevel {
        case 60 ... 100:
            .green
        case 10 ... 60:
            .orange
        case 0 ... 10:
            .red
        default:
            .red
        }
    }

    var body: some View {
        ZStack {
            if let imageName {
                Image(systemName: imageName)
                    .imageScale(imageScale)
                    .modify {
                        if deviceTypeName == "left insole" {
                            $0.scaleEffect(x: -1)
                        }
                    }
            }

            ProgressView(value: .init(batteryLevelProgress))
                .progressViewStyle(.circular)
                .tint(color)
            if isCharging {
                VStack {
                    Image(systemName: "bolt.fill")
                        .imageScale(.medium)
                        .offset(y: -5)
                    Spacer()
                }
            }
        }
    }
}
