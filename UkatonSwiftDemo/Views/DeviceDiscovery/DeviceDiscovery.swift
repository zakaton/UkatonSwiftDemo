import SwiftUI
import UkatonKit

struct DeviceDiscovery: View {
    @ObservedObject private var bluetoothManager: UKBluetoothManager = .shared

    @StateObject private var navigationCoordinator: NavigationCoordinator = .init()

    var isWatch: Bool {
        #if os(watchOS)
        true
        #else
        false
        #endif
    }

    var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
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
                let button = Button {
                    bluetoothManager.toggleDeviceScan()
                } label: {
                    if bluetoothManager.isScanning {
                        Label("stop scan", systemImage: "antenna.radiowaves.left.and.right")
                    }
                    else {
                        Label("start scan", systemImage: "antenna.radiowaves.left.and.right.slash")
                    }
                }
                #if os(watchOS)
                ToolbarItem(placement: .topBarTrailing) {
                    button
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    button
                }
                #endif
            }
        }
        .environmentObject(navigationCoordinator)
    }
}

#Preview {
    DeviceDiscovery()
        .frame(maxWidth: 350, minHeight: 300)
}
