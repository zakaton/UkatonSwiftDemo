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
            HStack {
                DiscoveredDeviceRowHeader(discoveredDevice: $discoveredDevice)
                Spacer()
                if mission.isConnected {
                    Button(action: {
                        onSelectDevice?()
                    }) {
                        Label("select", systemImage: "chevron.right.circle")
                            .labelStyle(LabelSpacing(spacing: 4))
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            #if os(tvOS)
            .focusSection()
            #endif
            DiscoveredDeviceRowConnection(discoveredDevice: $discoveredDevice)
            #if os(tvOS)
                .focusSection()
            #endif
            DiscoveredDeviceRowStatus(discoveredDevice: $discoveredDevice)
        }
        .padding()
        #if os(tvOS)
            .focusSection()
        #endif
    }
}

#Preview {
    DiscoveredDeviceRow(discoveredDevice: .constant(.none))
        .frame(maxWidth: 300)
}
