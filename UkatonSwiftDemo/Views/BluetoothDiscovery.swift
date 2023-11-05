import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros

@StaticLogger
struct BluetoothDiscovery: View {
    @State private var path = NavigationPath()

    @ObservedObject private var bluetoothManager: UKBluetoothManager = .shared
    var body: some View {
        NavigationStack(path: $path) {
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
                    ForEach($bluetoothManager.discoveredDevices) { $device in
                        DiscoveredBluetoothDeviceRow(device: $device, mission: device.mission ?? .None) {
                            path.append(device)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationDestination(for: UKDiscoveredBluetoothDevice.self) { _ in
                BluetoothDeviceDetail()
            }
            .navigationTitle("Ukaton Devices")
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
        .frame(maxWidth: 320, minHeight: 300)
}
