import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros

@StaticLogger
struct DiscoveredBluetoothDeviceRow: View {
    @Binding var device: UKDiscoveredBluetoothDevice
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

                if device.isConnected {
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
                if !device.isConnected {
                    Text("connect via:")
                    Button(action: {
                        print("connect via ble")
                    }, label: {
                        Text("bluetooth")
                            .accessibilityLabel("connect via bluetooth")
                    })
                    .buttonStyle(.borderedProminent)
                    if device.isConnectedToWifi {
                        Button(action: {
                            print("connect via wifi")
                        }, label: {
                            Text("wifi")
                                .accessibilityLabel("connect via wifi")
                        })
                        .buttonStyle(.borderedProminent)
                    }
                    Spacer()
                }
                else {
                    Button(action: {
                        print("disconnect")
                    }, label: {
                        Text("disconnect")
                    })
                    .buttonStyle(.borderedProminent)
                }
            }
            HStack(spacing: 20) {
                Label(String(format: "%3d", device.rssi.intValue), systemImage: "cellularbars")
                if !device.timestampDifference_ms.isNaN {
                    Label(String(format: "%6.2fms", device.timestampDifference_ms), systemImage: "stopwatch")
                }
                if device.isConnectedToWifi, let ipAddress = device.ipAddress, !ipAddress.isEmpty {
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
