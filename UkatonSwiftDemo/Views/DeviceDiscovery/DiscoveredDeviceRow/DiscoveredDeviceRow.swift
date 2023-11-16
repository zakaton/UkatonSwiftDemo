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
        let layout = isWatch ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())

        VStack {
            layout {
                DiscoveredDeviceRowHeader(discoveredDevice: $discoveredDevice)

                Spacer()

                if mission.isConnected {
                    Button(action: {
                        onSelectDevice?()
                    }, label: {
                        Label("select", systemImage: "chevron.right.circle")
                    })
                    .buttonStyle(.bordered)
                }
            }
            DiscoveredDeviceRowConnection(discoveredDevice: $discoveredDevice)
        }
        .padding()
    }
}

#Preview {
    DiscoveredDeviceRow(discoveredDevice: .constant(.none))
        .frame(maxWidth: 300)
}
