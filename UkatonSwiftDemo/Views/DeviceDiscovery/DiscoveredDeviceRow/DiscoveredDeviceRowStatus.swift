import SwiftUI
import UkatonKit

struct DiscoveredDeviceRowStatus: View {
    @Binding var discoveredDevice: UKDiscoveredBluetoothDevice
    let mission: UKMission

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

    let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.usesSignificantDigits = true
        nf.alwaysShowsDecimalSeparator = true
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 3
        nf.minimumIntegerDigits = 1
        nf.minimumSignificantDigits = 2
        nf.maximumSignificantDigits = 3
        return nf
    }()

    func formatTimestampDifference(_ timestampDifference: Double) -> String? {
        guard var string = numberFormatter.string(for: timestampDifference) else {
            return nil
        }

        while string.count < 5 {
            string += "0"
        }

        return string
    }

    var body: some View {
        let layout = isWatch ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout(spacing: 15))

        layout {
            if !mission.isConnected {
                HStack(spacing: 15) {
                    if let rssi = discoveredDevice.rssi {
                        Label(String(format: "%3d", rssi.intValue), systemImage: "cellularbars")
                    }
                    if !discoveredDevice.timestampDifference_ms.isNaN, let string = formatTimestampDifference(discoveredDevice.timestampDifference_ms) {
                        Label(string, systemImage: "stopwatch")
                    }
                }
            }
            if mission.isConnected, batteryLevel != .zero {
                Label("\(batteryLevel)%", systemImage: batteryLevelSystemImage)
            }
            if discoveredDevice.isConnectedToWifi, let ipAddress = discoveredDevice.ipAddress, !ipAddress.isEmpty {
                Label(ipAddress, systemImage: "wifi")
            }
        }
        .onReceive(mission.batteryLevelSubject, perform: { batteryLevel = $0
        })
        .labelStyle(LabelSpacing(spacing: 4))
        .font(Font.system(isWatch ? .caption2 : .caption, design: .monospaced))
        .padding(.top, 2)
    }
}

#Preview {
    DiscoveredDeviceRowStatus(discoveredDevice: .constant(.none))
}
