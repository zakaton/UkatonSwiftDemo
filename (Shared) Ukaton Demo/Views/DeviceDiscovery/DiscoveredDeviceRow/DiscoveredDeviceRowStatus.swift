import SwiftUI
import UkatonKit

struct DiscoveredDeviceRowStatus: View {
    @Binding var discoveredDevice: UKDiscoveredBluetoothDevice
    @ObservedObject var mission: UKMission

    private var bluetoothManager: UKBluetoothManager = .shared
    @State private var isScanning: Bool = false

    init(discoveredDevice: Binding<UKDiscoveredBluetoothDevice>) {
        self._discoveredDevice = discoveredDevice
        self.mission = discoveredDevice.wrappedValue.mission
    }

    var isWatch: Bool {
        #if os(watchOS)
            true
        #else
            false
        #endif
    }

    @State private var batteryLevel: UKBatteryLevel = .zero
    var batteryLevelSystemImage: String {
        switch batteryLevel {
        case 75 ..< 100:
            "battery.100"
        case 50 ..< 75:
            "battery.75"
        case 25 ..< 50:
            "battery.25"
        default:
            "battery.0"
        }
    }

    var batteryLevelColor: Color {
        switch batteryLevel {
        case 75 ..< 100:
            .green
        case 50 ..< 75:
            .orange
        case 25 ..< 50:
            .red
        default:
            .red
        }
    }

    var body: some View {
        let layout = isWatch ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout(spacing: 15))

        layout {
            if isScanning, !mission.isConnected {
                HStack(spacing: 15) {
                    if let rssi = discoveredDevice.rssi {
                        Label(String(format: "%3d", rssi.intValue), systemImage: "cellularbars")
                    }
                    if !discoveredDevice.timestampDifference_ms.isNaN, let string = discoveredDevice.timestampDifference_ms.string {
                        Label(string, systemImage: "stopwatch")
                    }
                }
            }
            if mission.isConnected {
                Label {
                    Text("\(batteryLevel)%")
                } icon: {
                    Image(systemName: batteryLevelSystemImage)
                        .foregroundColor(batteryLevelColor)
                }
            }
            if discoveredDevice.isConnectedToWifi, let ipAddress = discoveredDevice.ipAddress, !ipAddress.isEmpty {
                Label(ipAddress, systemImage: "wifi")
            }
        }
        .onReceive(mission.batteryLevelSubject, perform: { batteryLevel = $0
        })
        .onReceive(bluetoothManager.$isScanning, perform: { isScanning = $0
        })
        .labelStyle(LabelSpacing(spacing: 4))
        .font(Font.system(isWatch ? .caption2 : .caption, design: .monospaced))
        .padding(.top, 2)
    }
}

#Preview {
    DiscoveredDeviceRowStatus(discoveredDevice: .constant(.none))
    #if os(macOS)
        .frame(maxWidth: 300)
    #endif
}