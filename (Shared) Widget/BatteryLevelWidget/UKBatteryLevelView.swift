import AppIntents
import SwiftUI
import UkatonKit
import WidgetKit

struct UKBatteryLevelView: View {
    var missionDevice: UKMission
    var batteryLevel: UKBatteryLevel {
        missionDevice.batteryLevel
    }

    var batteryLevelProgress: Double {
        guard !missionDevice.isNone else { return .zero }
        return .init(batteryLevel) / 100
    }

    var isCharging: Bool {
        missionDevice.isCharging
    }

    var deviceType: UKDeviceType {
        missionDevice.deviceType
    }

    @Environment(\.widgetFamily) var family

    var imageName: String? {
        guard !missionDevice.isNone else { return nil }

        return switch deviceType {
        case .leftInsole, .rightInsole:
            "shoe.fill"
        case .motionModule:
            "rotate.3d.fill"
        }
    }

    private var imageScale: Image.Scale {
        switch family {
        case .accessoryCircular:
            .large
        default:
            .medium
        }
    }

    var color: Color {
        guard !missionDevice.isNone else { return .gray }

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
                        if deviceType == .leftInsole {
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
