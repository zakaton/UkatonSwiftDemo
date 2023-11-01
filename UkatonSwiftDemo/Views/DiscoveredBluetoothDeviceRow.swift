import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros

@StaticLogger
struct DiscoveredBluetoothDeviceRow: View {
    var device: UKDiscoveredBluetoothDevice
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

                Button(action: {
                    if device.isConnected {
                        print("disconnect")
                    }
                    else {
                        print("connect")
                    }
                }, label: {
                    if device.isConnected {
                        Text("disconnect")
                    }
                    else {
                        Text("connect")
                    }
                })
            }
            HStack {
                Label(String(format: "%3d", device.rssi.intValue), systemImage: "cellularbars")
                Label(String(format: "%6.2fms", device.timestampDifference_ms), systemImage: "stopwatch")
                if device.isConnectedToWifi, let ipAddress = device.ipAddress, !ipAddress.isEmpty {
                    Label(ipAddress, systemImage: "wifi")
                }
                Spacer()
            }
            // .font(.caption)
            // .font(Font.monospacedDigit(.caption)())
            .font(Font.system(.caption, design: .monospaced))
        }
        .padding()
    }
}
