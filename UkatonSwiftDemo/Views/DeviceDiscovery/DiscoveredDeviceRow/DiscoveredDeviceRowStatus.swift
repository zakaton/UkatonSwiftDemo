import SwiftUI
import UkatonKit

struct DiscoveredDeviceRowStatus: View {
    @Binding var discoveredDevice: UKDiscoveredBluetoothDevice
    let mission: UKMission

    init(discoveredDevice: Binding<UKDiscoveredBluetoothDevice>) {
        self._discoveredDevice = discoveredDevice
        self.mission = discoveredDevice.wrappedValue.mission
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

    var body: some View {
        HStack(spacing: 15) {
            if !mission.isConnected {
                if let rssi = discoveredDevice.rssi {
                    Label(String(format: "%3d", rssi.intValue), systemImage: "cellularbars")
                }
                if !discoveredDevice.timestampDifference_ms.isNaN {
                    Label(String(format: discoveredDevice.timestampDifference_ms > 99 ? "%3.0f.ms" : "%4.2fms", discoveredDevice.timestampDifference_ms), systemImage: "stopwatch")
                }
            }
            if discoveredDevice.isConnectedToWifi, let ipAddress = discoveredDevice.ipAddress, !ipAddress.isEmpty {
                Label(ipAddress, systemImage: "wifi")
            }
            if mission.isConnected, batteryLevel != .zero {
                Label("\(batteryLevel)%", systemImage: batteryLevelSystemImage)
            }
        }
        .onReceive(mission.batteryLevelSubject, perform: { batteryLevel = $0
        })
        .labelStyle(LabelSpacing(spacing: 4))
        .font(Font.system(.caption, design: .monospaced))
        .padding(.top, 2)
    }
}

#Preview {
    DiscoveredDeviceRowStatus(discoveredDevice: .constant(.none))
}
