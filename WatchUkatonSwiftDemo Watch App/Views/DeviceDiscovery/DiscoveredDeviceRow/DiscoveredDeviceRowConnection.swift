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
        VStack {
            if connectionStatus == .connected || connectionStatus == .disconnecting {
                Button(role: .destructive, action: {
                    discoveredDevice.disconnect()
                }, label: {
                    Text("disconnect")
                })
                .matchedGeometryEffect(id: "Button", in: animation)
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
                    .matchedGeometryEffect(id: "Button", in: animation)
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
                    .matchedGeometryEffect(id: "Button", in: animation)
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
        .onReceive(mission.$connectionStatus, perform: { newConnectionStatus in
            withAnimation {
                self.connectionStatus = newConnectionStatus
            }
        })
    }
}

#Preview {
    DiscoveredDeviceRowConnection(discoveredDevice: .constant(.none))
        .frame(maxWidth: 300)
}
