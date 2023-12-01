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

    @State private var batteryLevel: UKBatteryLevel = .zero
    var batteryLevelSystemImage: String {
        switch batteryLevel {
        case 85 ... 100:
            "battery.100"
        case 65 ... 85:
            "battery.75"
        case 35 ... 65:
            "battery.50"
        case 15 ... 35:
            "battery.25"
        default:
            "battery.0"
        }
    }

    var batteryLevelColor: Color {
        switch batteryLevel {
        case 70 ... 100:
            .green
        case 25 ... 70:
            .orange
        case 0 ... 25:
            .red
        default:
            .red
        }
    }

    var body: some View {
        let layout = isWatch ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout(spacing: 15))

        layout {
            if isScanning, mission.connectionStatus == .notConnected {
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
