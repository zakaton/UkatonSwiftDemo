import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros

@StaticLogger
struct DiscoveredBluetoothDeviceRow: View {
    @Binding var device: UKDiscoveredBluetoothDevice
    @ObservedObject var mission: UKMission

    var onSelectDevice: () -> Void
    var body: some View {
        VStack {
            HStack {
                VStack {
                    VStack(alignment: .leading) {
                        Text(device.name)
                            .font(.title2)
                            .bold()
                        if let type = device.type {
                            Text(type.name)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Spacer()

                if device.mission?.connectionStatus == .connected {
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
                if device.mission?.connectionStatus == .connected {
                    Button(action: {
                        print("disconnect")
                    }, label: {
                        Text("disconnect")
                    })
                    .buttonStyle(.borderedProminent)
                }
                else {
                    Text("connect via:")
                    Button(action: {
                        print("connect via ble")
                        device.connect(type: .bluetooth)
                    }, label: {
                        Text("bluetooth")
                            .accessibilityLabel("connect via bluetooth")
                    })
                    .buttonStyle(.borderedProminent)
                    if device.isConnectedToWifi {
                        Button(action: {
                            print("connect via wifi")
                            device.connect(type: .udp)
                        }, label: {
                            Text("wifi")
                                .accessibilityLabel("connect via wifi")
                        })
                        .buttonStyle(.borderedProminent)
                    }
                    Spacer()
                }
            }
            HStack(spacing: 15) {
                Label(String(format: "%3d", device.rssi.intValue), systemImage: "cellularbars")
                if !device.timestampDifference_ms.isNaN {
                    Label(String(format: "%6.2fms", device.timestampDifference_ms), systemImage: "stopwatch")
                }
                if device.isConnectedToWifi, let ipAddress = device.ipAddress, !ipAddress.isEmpty {
                    Label(ipAddress, systemImage: "wifi")
                }
                Spacer()
            }
            .labelStyle(LabelSpacing(spacing: 4))
            .font(Font.system(.caption, design: .monospaced))
            .padding(.top, 2)
        }
        .padding()
    }
}
