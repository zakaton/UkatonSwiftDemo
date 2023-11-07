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
        mission.connectionType?.requiresWifi == false
    }

    @State private var newWifiSsid: String = ""
    @State private var newWifiPassword: String = ""
    @State private var showWifiPassword: Bool = false
    @State private var newShouldConnectToWifi: Bool

    init(mission: UKMission) {
        self.mission = mission
        self.newDeviceType = mission.deviceType
        self.newShouldConnectToWifi = mission.shouldConnectToWifi
    }

    var body: some View {
        List {
            Section {
                Text("__name:__ \(mission.name)")
                HStack {
                    TextField("new name", text: $newName)
                    Button(action: {
                        try? mission.setName(newName)
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
                    try? mission.setDeviceType(newDeviceType)
                }

                Text("__battery level:__ \(String(mission.batteryLevel))%")
            } header: {
                Text("Device Information")
            }

            Section {
                if canEditWifi {
                    Toggle(isOn: $newShouldConnectToWifi) {
                        Text("Connect to wifi?")
                            .bold()
                    }
                    .onChange(of: newShouldConnectToWifi) {
                        try? mission.setWifiShouldConnect(newShouldConnectToWifi)
                    }
                }
                Text("__connected?__ \(String(mission.isConnectedToWifi))")
                if mission.isConnectedToWifi, let ipAddress = mission.ipAddress {
                    Text("__ip address__: \(ipAddress)")
                }

                Text("__ssid__: \(mission.wifiSsid)")
                if canEditWifi {
                    HStack {
                        TextField("new wifi ssid", text: $newWifiSsid)
                        Button(action: {
                            try? mission.setWifiSsid(newWifiSsid)
                            newWifiSsid = ""
                        }) {
                            Text("update")
                        }
                        .disabled(newWifiSsid.isEmpty)
                    }
                }
                Text("__password__: \(mission.wifiPassword)")
                if canEditWifi {
                    HStack {
                        Button(action: {
                            showWifiPassword.toggle()
                        }) {
                            Image(systemName: showWifiPassword ? "eye" : "eye.slash")
                        }

                        if showWifiPassword {
                            TextField("new wifi password", text: $newWifiPassword)
                                .disableAutocorrection(true)
                        }
                        else {
                            SecureField("new wifi password", text: $newWifiPassword)
                                .disableAutocorrection(true)
                        }

                        Button(action: {
                            try? mission.setWifiPassword(newWifiPassword)
                            newWifiPassword = ""
                        }) {
                            Text("update")
                        }
                        .disabled(newWifiPassword.isEmpty)
                    }
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
