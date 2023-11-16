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

    var connectionStatus: UKConnectionStatus {
        mission.connectionStatus
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
                    }, label: {
                        Label("select", systemImage: "chevron.right.circle")
                            .labelStyle(.iconOnly)
                            .imageScale(.large)
                    })
                    .buttonStyle(.accessoryBar)
                }
            }
            HStack {
                if connectionStatus == .connected || connectionStatus == .disconnecting {
                    Text("connected via \(mission.connectionType!.name)")
                    Button(role: .destructive, action: {
                        discoveredDevice.disconnect()
                    }, label: {
                        Text("disconnect")
                    })
                    .buttonStyle(.borderedProminent)
                    Spacer()
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
                        #if !os(watchOS)
                        if discoveredDevice.isConnectedToWifi {
                            Button(action: {
                                discoveredDevice.connect(type: .udp)
                            }, label: {
                                Text("udp")
                                    .accessibilityLabel("connect via udp")
                            })
                            .buttonStyle(.borderedProminent)
                        }
                        #endif
                    }
                    else {
                        Text("connecting via \(mission.connectionType!.name)...")
                        Button(role: .cancel, action: {
                            discoveredDevice.disconnect()
                        }, label: {
                            Text("cancel")
                                .accessibilityLabel("cancel connection")
                        })
                        .buttonStyle(.borderedProminent)
                    }

                    Spacer()
                }
            }
            DiscoveredDeviceRowStatus(discoveredDevice: $discoveredDevice)
        }
        .padding()
    }
}

#Preview {
    DiscoveredDeviceRow(discoveredDevice: .constant(.none))
        .frame(maxWidth: 300)
}
