import SwiftUI
import UkatonKit

struct DeviceDiscovery: View {
    @Environment(\.scenePhase) var scenePhase

    @ObservedObject private var bluetoothManager: UKBluetoothManager = .shared

    @StateObject private var navigationCoordinator: NavigationCoordinator = .init()

    var isWatch: Bool {
        #if os(watchOS)
        true
        #else
        false
        #endif
    }

    @State private var wasScanning: Bool = false

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

                            #if os(watchOS) || os(iOS)
                            if bluetoothManager.isScanning {
                                bluetoothManager.stopScanningForDevices()
                            }
                            #endif
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
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .foregroundColor(.blue)
                            .accessibilityLabel("stop scan")
                    }
                    else {
                        Image(systemName: "antenna.radiowaves.left.and.right.slash")
                            .accessibilityLabel("start scan")
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
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                if bluetoothManager.isScanning {
                    wasScanning = true
                    bluetoothManager.stopScanningForDevices()
                }

            case .active:
                if wasScanning {
                    wasScanning = false
                    bluetoothManager.scanForDevices()
                }
            default:
                break
            }
        }
    }
}

#Preview {
    DeviceDiscovery()
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
