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
                            Text(type.name)
                                .foregroundColor(.secondary)
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
                    Button(role: .destructive, action: {
                        print("disconnect")
                        discoveredDevice.disconnect()
                    }, label: {
                        Text("disconnect")
                    })
                    .buttonStyle(.borderedProminent)
                }
                else {
                    if connectionStatus == .notConnected {
                        Text("connect via:")
                        Button(action: {
                            print("connect via ble")
                            discoveredDevice.connect(type: .bluetooth)
                        }, label: {
                            Text("bluetooth")
                                .accessibilityLabel("connect via bluetooth")
                        })
                        .buttonStyle(.borderedProminent)
                        if discoveredDevice.isConnectedToWifi {
                            Button(action: {
                                print("connect via udp")
                                discoveredDevice.connect(type: .udp)
                            }, label: {
                                Text("udp")
                                    .accessibilityLabel("connect via udp")
                            })
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    else {
                        Text("connecting...")
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
                        Label(String(format: "%6.2fms", discoveredDevice.timestampDifference_ms), systemImage: "stopwatch")
                    }
                }
                if discoveredDevice.isConnectedToWifi, let ipAddress = discoveredDevice.ipAddress, !ipAddress.isEmpty {
                    Label(ipAddress, systemImage: "wifi")
                }
            }
            .labelStyle(LabelSpacing(spacing: 4))
            .font(Font.system(.caption, design: .monospaced))
            .padding(.top, 2)
        }
        .padding()
    }
}
