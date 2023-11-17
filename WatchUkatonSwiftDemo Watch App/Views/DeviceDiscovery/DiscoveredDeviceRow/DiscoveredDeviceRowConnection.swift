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

    @State private var connectingAnimationAmount: CGFloat = 1

    var body: some View {
        if connectionStatus == .connected || connectionStatus == .disconnecting {
            Button(role: .destructive, action: {
                discoveredDevice.disconnect()
            }, label: {
                Text("disconnect")
            })
            .tint(.red)
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
                .tint(.blue)
            }
            else {
                Button(role: .cancel, action: {
                    discoveredDevice.disconnect()
                }, label: {
                    Text("connecting...")
                        .accessibilityLabel("cancel connection")
                })
                .tint(.cyan)
                .buttonStyle(.borderedProminent)
                .scaleEffect(connectingAnimationAmount)
                .animation(
                    .easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true),
                    value: connectingAnimationAmount)
                .onAppear {
                    connectingAnimationAmount = 0.97
                }
                .onDisappear {
                    connectingAnimationAmount = 1
                }
            }
        }
    }
}

#Preview {
    DiscoveredDeviceRowConnection(discoveredDevice: .constant(.none))
        .frame(maxWidth: 300)
}
