import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros

@StaticLogger
struct BluetoothDiscoveryView: View {
    @ObservedObject private var bluetoothManager: UKBluetoothManager = .shared
    var body: some View {
        NavigationStack {
            List {
                if bluetoothManager.discoveredPeripherals.isEmpty {
                    if bluetoothManager.isScanning {
                        Text("scanning for devices...")
                    }
                    else {
                        Text("not scanning for devices")
                    }
                }
                else {
                    ForEach(bluetoothManager.discoveredPeripherals) { discoveredPeripheral in
                        Text(discoveredPeripheral.peripheral.name ?? "undefined")
                    }
                }
            }
            .navigationTitle("Ukaton Bluetooth Devices")
            .toolbar {
                Button {
                    bluetoothManager.toggleDeviceScan()
                } label: {
                    if bluetoothManager.isScanning {
                        Label("stop scan", systemImage: "wifi")
                    }
                    else {
                        Label("start scan", systemImage: "wifi.slash")
                    }
                }
            }
        }
    }
}

#Preview {
    BluetoothDiscoveryView()
        .frame(maxWidth: 300, minHeight: 300)
}
