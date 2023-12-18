import AppIntents
import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros
import WidgetKit

@StaticLogger
struct UKDeviceDiscoveryRow: View {
    var discoveredDeviceInformation: UKDiscoveredDeviceInformation
    var deviceInformation: UKDeviceInformation

    init(index: Int) {
        discoveredDeviceInformation = UKDeviceDiscoveryInformation.shared.getInformation(index: index) ?? .none
        deviceInformation = UKDevicesInformation.shared.getInformation(id: discoveredDeviceInformation.id) ?? .none
    }

    init(id: String) {
        discoveredDeviceInformation = UKDeviceDiscoveryInformation.shared.getInformation(id: id) ?? .none
        deviceInformation = UKDevicesInformation.shared.getInformation(id: discoveredDeviceInformation.id) ?? .none
    }

    init() {
        self.init(index: 0)
    }

    var isNone: Bool {
        discoveredDeviceInformation.isNone
    }

    var id: String {
        discoveredDeviceInformation.id
    }

    var connectionType: UKConnectionType? {
        deviceMetadata.connectionType
    }

    var connectionStatus: UKConnectionStatus? {
        deviceMetadata.connectionStatus
    }

    var isConnected: Bool {
        // TODO: - is this an issue?
        discoveredDeviceInformation.isConnected
    }

    var deviceMetadata: any UKAppGroupDeviceMetadata {
        isConnected ? deviceInformation : discoveredDeviceInformation
    }

    var isCharging: Bool {
        deviceInformation.isCharging
    }

    var deviceType: UKDeviceType {
        deviceMetadata.deviceType
    }

    var batteryLevel: UKBatteryLevel {
        deviceInformation.batteryLevel
    }

    var name: String {
        deviceMetadata.name
    }

    var isConnectedToWifi: Bool {
        deviceMetadata.isConnectedToWifi
    }

    var link: URL {
        .init(string: "ukaton-demo://select-device?id=\(id)")!
    }

    var emoji: String {
        switch deviceType {
        case .motionModule:
            "📦"
        case .leftInsole, .rightInsole:
            "👟"
        }
    }

    var batteryLevelProgress: Double {
        guard !isNone else { return .zero }
        return .init(batteryLevel) / 100
    }

    var batteryLevelView: some View {
        if !isNone {
            Text("\(batteryLevel)%")
        }
        else {
            Text(" ")
        }
    }

    var batteryLevelImageString: String? {
        guard !isNone else { return nil }
        guard !isCharging else { return "battery.100.bolt" }

        return switch batteryLevel {
        case 85 ... 100:
            "battery.100"
        case 65 ... 85:
            "battery.75"
        case 35 ... 65:
            "battery.50"
        case 15 ... 35:
            "battery.25"
        default:
            "battery.0"
        }
    }

    var batteryLevelColor: Color {
        guard !isNone else { return .gray }

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

    @ViewBuilder
    var batteryLevelImage: some View {
        if let batteryLevelImageString {
            Image(systemName: batteryLevelImageString)
                .foregroundColor(batteryLevelColor)
        }
    }

    @Environment(\.widgetFamily) var family

    var imageName: String? {
        guard !isNone else { return nil }

        return switch deviceType {
        case .leftInsole, .rightInsole:
            "shoe"
        default:
            "rotate.3d"
        }
    }

    private var imageScale: Image.Scale {
        switch family {
        case .systemLarge, .systemExtraLarge:
            .medium
        default:
            .medium
        }
    }

    @ViewBuilder
    private var image: some View {
        if let imageName {
            Image(systemName: imageName)
                .imageScale(imageScale)
                .modify {
                    if deviceType == .leftInsole {
                        $0.scaleEffect(x: -1)
                    }
                }
        }
    }

    var body: some View {
        switch family {
        case .systemLarge, .systemExtraLarge:
            if !isNone {
                HStack {
                    VStack {
                        HStack {
                            Text("\(name)")
                                .font(.title2)
                            Spacer()
                        }
                        HStack(spacing: 4) {
                            image
                            Text("\(deviceType.name)")
                            Spacer()
                        }
                    }
                    Spacer()
                    if isConnected {
                        batteryLevelView
                        batteryLevelImage
                    }
                }
                .padding(2)
            }

        default:
            Text("uncaught family \(family.debugDescription)")
        }
    }
}
