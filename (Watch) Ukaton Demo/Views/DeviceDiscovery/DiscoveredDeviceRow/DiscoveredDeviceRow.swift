import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros

@StaticLogger
struct DiscoveredDeviceRow: View {
    @Binding var discoveredDevice: UKDiscoveredBluetoothDevice
    @ObservedObject var mission: UKMission

    init(discoveredDevice: Binding<UKDiscoveredBluetoothDevice>, onSelectDevice: (() -> Void)? = nil) {
        self._discoveredDevice = discoveredDevice
        self.mission = discoveredDevice.wrappedValue.mission
        self.onSelectDevice = onSelectDevice
    }

    var onSelectDevice: (() -> Void)?
    var body: some View {
        VStack {
            if mission.isConnected {
                Button(action: {
                    onSelectDevice?()
                }) {
                    DiscoveredDeviceRowHeader(discoveredDevice: $discoveredDevice)
                }
                .buttonStyle(.borderedProminent)

            } else {
                DiscoveredDeviceRowHeader(discoveredDevice: $discoveredDevice)
            }
            DiscoveredDeviceRowConnection(discoveredDevice: $discoveredDevice)
            DiscoveredDeviceRowStatus(discoveredDevice: $discoveredDevice)
        }
        .padding()
    }
}

#Preview {
    DiscoveredDeviceRow(discoveredDevice: .constant(.none))
        .frame(maxWidth: 300)
}
