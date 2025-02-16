import Combine
import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros
#if !os(visionOS) && !os(tvOS)
import WidgetKit
#endif

@StaticLogger
struct DeviceDiscovery: View {
    @Environment(\.scenePhase) var scenePhase

    @ObservedObject private var bluetoothManager: UKBluetoothManager = .shared

    @ObservedObject var navigationCoordinator: NavigationCoordinator

    @State private var wasScanning: Bool = false

    #if !os(visionOS) && !os(tvOS)
    private var devicesInformation: UKDevicesInformation = .shared
    private var discoveredDevicesInformation: UKDeviceDiscoveryInformation = .shared
    #endif

    init(navigationCoordinator: NavigationCoordinator) {
        self.navigationCoordinator = navigationCoordinator
        #if !os(visionOS) && !os(tvOS)
        devicesInformation.listenForUpdates()
        discoveredDevicesInformation.listenForUpdates()
        #endif
    }

    var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
            List {
                if bluetoothManager.isScanning {
                    HStack {
                        Spacer()
                        Text("scanning for devices...")
                        Spacer()
                    }
                }
                if bluetoothManager.discoveredDevices.isEmpty {
                    if !bluetoothManager.isScanning {
                        HStack {
                            Spacer()
                            if bluetoothManager.isScanning {
                                // Text("scanning for devices...")
                            }
                            else {
                                Text("not scanning for devices")
                            }
                            Spacer()
                        }
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
//        .onChange(of: scenePhase) { _, newPhase in
//            switch newPhase {
//            case .background:
//                if bluetoothManager.isScanning {
//                    wasScanning = true
//                    bluetoothManager.stopScanningForDevices()
//                }
//
//            case .active:
//                if wasScanning {
//                    wasScanning = false
//                    bluetoothManager.scanForDevices()
//                }
//            default:
//                break
//            }
//        }
        .onOpenURL { incomingURL in
            logger.debug("(DeviceDiscovery) App was opened via URL: \(incomingURL)")
            handleIncomingURL(incomingURL)
        }
    }

    private func handleIncomingURL(_ url: URL) {
        guard url.isDeeplink else {
            return
        }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let action = components.host
        else {
            logger.debug("Invalid URL")
            return
        }

        switch action {
        case "select-device":
            if let deviceId = components.queryItems?.first(where: { $0.name == "id" })?.value {
                if let discoveredDevice = bluetoothManager.discoveredDevices.first(where: { $0.mission.id == deviceId }) {
                    navigationCoordinator.path.removeLast(navigationCoordinator.path.count)
                    navigationCoordinator.path.append(discoveredDevice)
                }
                else {
                    logger.debug("no discovered device found for \(deviceId)")
                }
            }
            else {
                logger.debug("no id query found in url")
            }
        default:
            logger.debug("uncaught action \"\(action)\"")
        }
    }
}

#Preview {
    DeviceDiscovery(navigationCoordinator: .init())
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
