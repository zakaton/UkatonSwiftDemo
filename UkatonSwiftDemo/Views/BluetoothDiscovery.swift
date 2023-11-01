import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros

@StaticLogger
struct BluetoothDiscovery: View {
    @ObservedObject private var bluetoothManager: UKBluetoothManager = .shared
    var body: some View {
        NavigationStack {
            List {
                if bluetoothManager.discoveredDevices.isEmpty {
                    HStack {
                        Spacer()
                        if bluetoothManager.isScanning {
                            Text("scanning for devices...")
                        }
                        else {
                            Text("not scanning for devices")
                        }
                        Spacer()
                    }
                }
                else {
                    ForEach(bluetoothManager.discoveredDevices) { device in
                        NavigationLink {
                            BluetoothDeviceDetail()
                        } label: {
                            DiscoveredBluetoothDeviceRow(device: device)
                        }
                    }
                }
            }
            .navigationTitle("Ukaton Bluetooth Devices")
            .toolbar {
                Button {
                    bluetoothManager.toggleDeviceScan()
                } label: {
                    if bluetoothManager.isScanning {
                        Label("stop scan", systemImage: "antenna.radiowaves.left.and.right")
                    }
                    else {
                        Label("start scan", systemImage: "antenna.radiowaves.left.and.right.slash")
                    }
                }
            }
        }
    }
}

#Preview {
    BluetoothDiscovery()
        .frame(maxWidth: 400, minHeight: 300)
}
