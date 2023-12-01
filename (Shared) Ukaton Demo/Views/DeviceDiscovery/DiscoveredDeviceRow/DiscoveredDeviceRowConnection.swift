import SwiftUI
import UkatonKit

struct DiscoveredDeviceRowConnection: View {
    @Binding var discoveredDevice: UKDiscoveredBluetoothDevice
    let mission: UKMission
    var onSelectDevice: (() -> Void)?

    init(discoveredDevice: Binding<UKDiscoveredBluetoothDevice>, onSelectDevice: (() -> Void)? = nil) {
        self._discoveredDevice = discoveredDevice
        self.mission = discoveredDevice.wrappedValue.mission
        self.onSelectDevice = onSelectDevice
    }

    @State var connectionStatus: UKConnectionStatus = .notConnected

    @State private var connectingAnimationAmount: CGFloat = 1
    @Namespace private var animation

    var body: some View {
        HStack {
            if connectionStatus == .connected || connectionStatus == .disconnecting {
                Text("connected via \(mission.connectionType!.name)")
                Button(role: .destructive, action: {
                    discoveredDevice.disconnect()
                }, label: {
                    Text("disconnect")
                })
                .buttonStyle(.borderedProminent)
                .tint(.red)
                if !is_iOS {
                    Spacer()
                }
            }
            else {
                if connectionStatus == .notConnected {
                    Text("connect via:")
                    Button(action: {
                        discoveredDevice.connect(type: .bluetooth)
                    }, label: {
                        Text("bluetooth")
                            .accessibilityLabel("connect via bluetooth")
                    })
                    .buttonStyle(.borderedProminent)

                    if discoveredDevice.isConnectedToWifi {
                        Button(action: {
                            discoveredDevice.connect(type: .udp)
                        }, label: {
                            Text("udp")
                                .accessibilityLabel("connect via udp")
                        })
                        .buttonStyle(.borderedProminent)
                    }
                }
                else {
                    if is_iOS {
                        Spacer()
                    }
                    Button(role: .cancel, action: {
                        discoveredDevice.disconnect()
                    }, label: {
                        Text("connecting via \(mission.connectionType!.name)...")
                            .accessibilityLabel("cancel connection")
                    })
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

                Spacer()
            }
        }
        .onReceive(mission.$connectionStatus, perform: { newConnectionStatus in
            self.connectionStatus = newConnectionStatus
        })
    }
}

#Preview {
    DiscoveredDeviceRowConnection(discoveredDevice: .constant(.none))
#if os(macOS)
        .frame(maxWidth: 300)
#endif
}
