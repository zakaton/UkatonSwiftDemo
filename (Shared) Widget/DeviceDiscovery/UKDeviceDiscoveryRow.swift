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

    var ipAddress: String? {
        deviceMetadata.ipAddress
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
        case .systemLarge:
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

    @ViewBuilder
    var header: some View {
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
    }

    @ViewBuilder
    var footer: some View {
        HStack {
            if isConnectedToWifi, let ipAddress {
                HStack {
                    Label(ipAddress, systemImage: "wifi")
                }
            }
            if isConnected {
                HStack {
                    batteryLevelImage
                    batteryLevelView
                }
            }
        }
    }

    @ViewBuilder
    var connectionContent: some View {
        HStack {
            if connectionStatus == .connected || connectionStatus == .disconnecting {
                Text("connected via \(connectionType!.name)")
                Button(role: .destructive, intent: UKDisconnectFromDeviceIntent(deviceId: id), label: {
                    Text("disconnect")
                })
                .buttonStyle(.borderedProminent)
                .tint(.red)
                if !is_iOS {
                    Spacer()
                }
            }
            else {
                if connectionStatus == .notConnected {
                    Text("connect via:")
                    Button(intent: UKConnectToDeviceIntent(deviceId: id, connectionType: .bluetooth), label: {
                        Text("bluetooth")
                            .accessibilityLabel("connect via bluetooth")
                    })
                    .buttonStyle(.borderedProminent)

                    if isConnectedToWifi {
                        Button(intent: UKConnectToDeviceIntent(deviceId: id, connectionType: .udp), label: {
                            Text("udp")
                                .accessibilityLabel("connect via udp")
                        })
                        .buttonStyle(.borderedProminent)
                    }
                }
                else {
                    if let connectionType {
                        if is_iOS {
                            Spacer()
                        }
                        Button(role: .cancel, intent: UKDisconnectFromDeviceIntent(deviceId: id), label: {
                            Text("connecting via \(connectionType.name)...")
                                .accessibilityLabel("cancel connection")
                        })
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
    }

    var body: some View {
        HStack {
            VStack {
                VStack {
                    HStack {
                        header
                    }
                    connectionContent
                }
                footer
            }
            Spacer()
        }
        .padding(2)
    }
}
