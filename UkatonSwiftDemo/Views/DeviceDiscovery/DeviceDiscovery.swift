import SwiftUI
import UkatonKit

struct DeviceDiscovery: View {
    @ObservedObject private var bluetoothManager: UKBluetoothManager = .shared

    @EnvironmentObject var navigationCoordinator: NavigationCoordinator

    var body: some View {
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
                ForEach($bluetoothManager.discoveredDevices) { $discoveredDevice in
                    DiscoveredDeviceRow(discoveredDevice: $discoveredDevice) {
                        navigationCoordinator.path.append(discoveredDevice)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationDestination(for: UKDiscoveredBluetoothDevice.self) { discoveredDevice in
            DeviceDetail(mission: discoveredDevice.mission)
        }
        .navigationTitle("My devices")
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

#Preview {
    @StateObject var navigationCoordinator: NavigationCoordinator = .init()
    return NavigationStack(path: $navigationCoordinator.path) {
        DeviceDiscovery()
    }
    .environmentObject(navigationCoordinator)
    .frame(maxWidth: 350, minHeight: 300)
}
