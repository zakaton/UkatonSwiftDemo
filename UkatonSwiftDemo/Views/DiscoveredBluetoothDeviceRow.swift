import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros

@StaticLogger
struct DiscoveredBluetoothDeviceRow: View {
    @State var device: UKDiscoveredBluetoothDevice
    var body: some View {
        VStack {
            HStack {
                VStack {
                    VStack(alignment: .leading) {
                        Text(device.name)
                            .font(.title2)
                            .bold()
                        Text(device.type.name)
                            .foregroundColor(.secondary)
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
                Label(device.rssi.stringValue, systemImage: "cellularbars")
                Label("30ms", systemImage: "stopwatch")
                if device.isConnectedToWifi, let ipAddress = device.ipAddress, !ipAddress.isEmpty {
                    Label(ipAddress, systemImage: "wifi")
                }
                Spacer()
            }
            .font(.caption)
        }
        .padding()
    }
}
