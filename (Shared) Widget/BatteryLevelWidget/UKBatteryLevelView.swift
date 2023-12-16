import AppIntents
import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros
import WidgetKit

@StaticLogger
struct UKBatteryLevelView: View {
    init(index: Int) {
        deviceInformation = UKDevicesInformation.shared.getInformation(index: index) ?? .none
        logger.debug("UKBatteryLevelView \(index): \(UKDevicesInformation.shared.ids, privacy: .public)")
    }

    init(id: String) {
        deviceInformation = UKDevicesInformation.shared.getInformation(id: id) ?? .none
        logger.debug("UKBatteryLevelView \(id): \(UKDevicesInformation.shared.ids, privacy: .public)")
    }

    init() {
        self.init(index: 0)
    }

    var deviceInformation: UKDeviceInformation
    var batteryLevel: UKBatteryLevel {
        deviceInformation.batteryLevel
    }

    var batteryLevelProgress: Double {
        guard !deviceInformation.isNone else { return .zero }
        return .init(batteryLevel) / 100
    }

    var isCharging: Bool {
        deviceInformation.isCharging
    }

    var deviceType: UKDeviceType {
        deviceInformation.deviceType
    }

    @Environment(\.widgetFamily) var family

    var imageName: String? {
        guard !deviceInformation.isNone else { return nil }

        return switch deviceType {
        case .leftInsole, .rightInsole:
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
        guard !deviceInformation.isNone else { return .gray }

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
