import SwiftUI
import UkatonKit

struct DiscoveredDeviceRowConnection: View {
    @Binding var discoveredDevice: UKDiscoveredBluetoothDevice
    @ObservedObject var mission: UKMission
    var onSelectDevice: (() -> Void)?

    init(discoveredDevice: Binding<UKDiscoveredBluetoothDevice>, onSelectDevice: (() -> Void)? = nil) {
        self._discoveredDevice = discoveredDevice
        self.mission = discoveredDevice.wrappedValue.mission
        self.onSelectDevice = onSelectDevice
    }

    var connectionStatus: UKConnectionStatus {
        mission.connectionStatus
    }

    var body: some View {
        if connectionStatus == .connected || connectionStatus == .disconnecting {
            Button(role: .destructive, action: {
                discoveredDevice.disconnect()
            }, label: {
                Text("disconnect")
            })
            .buttonStyle(.borderedProminent)
        }
        else {
            if connectionStatus == .notConnected {
                Button(action: {
                    discoveredDevice.connect(type: .bluetooth)
                }, label: {
                    Text("connect")
                })
                .buttonStyle(.borderedProminent)
            }
            else {
                Button(role: .cancel, action: {
                    discoveredDevice.disconnect()
                }, label: {
                    Text("connecting...")
                        .accessibilityLabel("cancel connection")
                })
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    DiscoveredDeviceRowConnection(discoveredDevice: .constant(.none))
        .frame(maxWidth: 300)
}