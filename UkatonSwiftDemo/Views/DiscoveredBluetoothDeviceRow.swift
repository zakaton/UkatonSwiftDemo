import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros

@StaticLogger
struct DiscoveredBluetoothDeviceRow: View {
    @Binding var discoveredDevice: UKDiscoveredBluetoothDevice
    @ObservedObject var mission: UKMission
    var connectionStatus: UKConnectionStatus {
        mission.connectionStatus
    }

    var isConnected: Bool {
        mission.connectionStatus == .connected
    }

    var connectionType: UKConnectionType? {
        mission.connectionType
    }

    var deviceTypeSystemImage: String {
        switch discoveredDevice.type {
        case .motionModule:
            "rotate.3d"
        case .leftInsole, .rightInsole:
            "shoe"
        default:
            "questionmark"
        }
    }

    var batteryLevelSystemImage: String {
        if let batteryLevel = mission.batteryLevel {
            return switch batteryLevel {
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
        else {
            return "battery.0"
        }
    }

    var onSelectDevice: () -> Void
    var body: some View {
        VStack {
            HStack {
                VStack {
                    VStack(alignment: .leading) {
                        Text(discoveredDevice.name)
                            .font(.title2)
                            .bold()
                        if let type = discoveredDevice.type {
                            Label(type.name, systemImage: deviceTypeSystemImage)
                                .foregroundColor(.secondary)
                                .labelStyle(LabelSpacing(spacing: 4))
                        }
                    }
                }
                Spacer()

                if isConnected {
                    Button(action: {
                        onSelectDevice()
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
                    Text("connected via \(connectionType!.name)")
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
                        Text("connecting via \(connectionType!.name)...")
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
                if !isConnected {
                    Label(String(format: "%3d", discoveredDevice.rssi.intValue), systemImage: "cellularbars")
                    if !discoveredDevice.timestampDifference_ms.isNaN {
                        Label(String(format: discoveredDevice.timestampDifference_ms > 99 ? "%3.0f.ms" : "%4.2fms", discoveredDevice.timestampDifference_ms), systemImage: "stopwatch")
                    }
                }
                if discoveredDevice.isConnectedToWifi, let ipAddress = discoveredDevice.ipAddress, !ipAddress.isEmpty {
                    Label(ipAddress, systemImage: "wifi")
                }
                if isConnected, let batteryLevel = mission.batteryLevel {
                    Label("\(batteryLevel)%", systemImage: batteryLevelSystemImage)
                }
            }
            .labelStyle(LabelSpacing(spacing: 4))
            .font(Font.system(.caption, design: .monospaced))
            .padding(.top, 2)
        }
        .padding()
    }
}
