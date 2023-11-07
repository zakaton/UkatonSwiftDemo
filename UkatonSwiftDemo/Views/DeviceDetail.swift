import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros

@StaticLogger
struct DeviceDetail: View {
    @ObservedObject var mission: UKMission

    @State private var newName: String = ""

    @State private var newDeviceType: UKDeviceType

    var canEditWifi: Bool {
        mission.connectionType?.requiresWifi ?? false
    }

    init(mission: UKMission) {
        self.mission = mission
        self.newDeviceType = mission.deviceType
    }

    var body: some View {
        List {
            Section {
                Text("__name:__ \(mission.name)")
                HStack {
                    TextField("new name", text: $newName)
                    Button(action: {
                        try? mission.setName(newName: newName)
                        newName = ""
                    }) {
                        Text("update")
                    }
                    .disabled(newName.isEmpty)
                }

                Picker("__type__", selection: $newDeviceType) {
                    ForEach(UKDeviceType.allCases) { deviceType in
                        Text(deviceType.name)
                    }
                }
                .onChange(of: newDeviceType) {
                    try? mission.setDeviceType(newDeviceType: newDeviceType)
                }

                Text("__battery level:__ \(String(mission.batteryLevel))%")
            } header: {
                Text("Device Information")
            }

            Section {
                Text("__connected?__ \(String(mission.isConnectedToWifi))")
                Text("__ssid__: \(mission.wifiSsid)")
                if canEditWifi {
                    // TODO: - update ssid
                }
                Text("__password__: \(mission.wifiSsid)")
                if canEditWifi {
                    // TODO: - update password
                }

                if canEditWifi {
                    // TODO: - toggle connection
                }

                if let ipAddress = mission.ipAddress {
                    Text("__ip address__: \(ipAddress)")
                }

            } header: {
                Text("Wifi")
            }
        }
        .navigationTitle(mission.name)
    }
}

#Preview {
    DeviceDetail(mission: .none)
        .frame(maxWidth: 300, maxHeight: 300)
}
