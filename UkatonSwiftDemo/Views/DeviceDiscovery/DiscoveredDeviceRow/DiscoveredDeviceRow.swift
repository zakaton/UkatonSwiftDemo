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

    var isWatch: Bool {
        #if os(watchOS)
            true
        #else
            false
        #endif
    }

    var onSelectDevice: (() -> Void)?
    var body: some View {
        VStack {
            if isWatch {
                if mission.isConnected {
                    Button(action: {
                        onSelectDevice?()
                    }) {
                        DiscoveredDeviceRowHeader(discoveredDevice: $discoveredDevice)
                    }.buttonStyle(.borderedProminent)
                } else {
                    DiscoveredDeviceRowHeader(discoveredDevice: $discoveredDevice)
                }
            } else {
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
