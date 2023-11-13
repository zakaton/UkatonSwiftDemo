import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros

@StaticLogger
struct DiscoveredDeviceRow: View {
    @Binding var discoveredDevice: UKDiscoveredBluetoothDevice
    @ObservedObject var mission: UKMission
    var connectionStatus: UKConnectionStatus {
        mission.connectionStatus
    }

    var name: String {
        if !mission.isNone {
            return mission.name
        }
        else {
            return discoveredDevice.name
        }
    }

    var type: UKDeviceType? {
        if !mission.isNone {
            return mission.deviceType
        }
        else {
            return discoveredDevice.type
        }
    }

    var deviceTypeSystemImage: String {
        switch type {
        case .motionModule:
            "rotate.3d"
        case .leftInsole, .rightInsole:
            "shoe"
        default:
            "questionmark"
        }
    }

    @State private var batteryLevel: UKBatteryLevel = .zero
    var batteryLevelSystemImage: String {
        switch batteryLevel {
        case 75 ..< 100:
            "battery.100"
        case 50 ..< 75:
            "battery.75"
        case 25 ..< 50:
            "battery.25"
        default:
            "battery.0"
        }
    }

    var onSelectDevice: (() -> Void)?
    var body: some View {
        VStack {
            HStack {
                VStack {
                    VStack(alignment: .leading) {
                        Text(name)
                            .font(.title2)
                            .bold()
                        if let type {
                            Label(type.name, systemImage: deviceTypeSystemImage)
                                .foregroundColor(.secondary)
                                .labelStyle(LabelSpacing(spacing: 4))
                        }
                    }
                }
                Spacer()

                if mission.isConnected {
                    Button(action: {
                        onSelectDevice?()
                    }, label: {
                        Label("select", systemImage: "chevron.right.circle")
                            .labelStyle(.iconOnly)
                            .imageScale(.large)
                    })
                    .buttonStyle(.borderedProminent)
                }
            }
            HStack {
                if connectionStatus == .connected || connectionStatus == .disconnecting {
                    Text("connected via \(mission.connectionType!.name)")
                    Button(role: .destructive, action: {
                        discoveredDevice.disconnect()
                    }, label: {
                        Text("disconnect")
                    })
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                else {
                    if connectionStatus == .notConnected {
                        Text("connect via:")
                        Button(action: {
                            discoveredDevice.connect(type: .bluetooth)
                        }, label: {
                            Text("bluetooth")
                                .accessibilityLabel("connect via bluetooth")
                        })
                        .buttonStyle(.borderedProminent)
                        if discoveredDevice.isConnectedToWifi {
                            Button(action: {
                                discoveredDevice.connect(type: .udp)
                            }, label: {
                                Text("udp")
                                    .accessibilityLabel("connect via udp")
                            })
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    else {
                        Text("connecting via \(mission.connectionType!.name)...")
                        Button(role: .cancel, action: {
                            discoveredDevice.disconnect()
                        }, label: {
                            Text("cancel")
                                .accessibilityLabel("cancel connection")
                        })
                        .buttonStyle(.borderedProminent)
                    }

                    Spacer()
                }
            }
            HStack(spacing: 15) {
                if !mission.isConnected {
                    if let rssi = discoveredDevice.rssi {
                        Label(String(format: "%3d", rssi.intValue), systemImage: "cellularbars")
                    }
                    if !discoveredDevice.timestampDifference_ms.isNaN {
                        Label(String(format: discoveredDevice.timestampDifference_ms > 99 ? "%3.0f.ms" : "%4.2fms", discoveredDevice.timestampDifference_ms), systemImage: "stopwatch")
                    }
                }
                if discoveredDevice.isConnectedToWifi, let ipAddress = discoveredDevice.ipAddress, !ipAddress.isEmpty {
                    Label(ipAddress, systemImage: "wifi")
                }
                if mission.isConnected, batteryLevel != .zero {
                    Label("\(batteryLevel)%", systemImage: batteryLevelSystemImage)
                }
            }
            .onReceive(mission.batteryLevelSubject, perform: { batteryLevel = $0
            })
            .labelStyle(LabelSpacing(spacing: 4))
            .font(Font.system(.caption, design: .monospaced))
            .padding(.top, 2)
        }
        .padding()
    }
}

#Preview {
    DiscoveredDeviceRow(discoveredDevice: .constant(.none), mission: .none)
        .frame(maxWidth: 300)
}
