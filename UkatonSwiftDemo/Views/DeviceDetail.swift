import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros

@StaticLogger
struct DeviceDetail: View {
    @ObservedObject var mission: UKMission

    @State private var newName: String = ""
    @State private var newDeviceType: UKDeviceType

    var requiresWifi: Bool {
        mission.connectionType?.requiresWifi == true
    }

    var canEditWifi: Bool {
        requiresWifi == false
    }

    @State private var newWifiSsid: String = ""
    @State private var newWifiPassword: String = ""
    @State private var showWifiPassword: Bool = false
    @State private var showNewWifiPassword: Bool = false
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
                        .autocorrectionDisabled()
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
                        newWifiSsid = ""
                        newWifiPassword = ""
                        try? mission.setWifiShouldConnect(newShouldConnectToWifi)
                    }
                }
                Text("__connected?__ \(String(mission.isConnectedToWifi))")

                if mission.isConnectedToWifi, let ipAddress = mission.ipAddress {
                    Text("__ip address__: \(ipAddress)")
                }

                if !requiresWifi {
                    Text("__ssid__: \(mission.wifiSsid)")
                    if canEditWifi {
                        HStack {
                            TextField("new wifi ssid", text: $newWifiSsid)
                                .autocorrectionDisabled()
                                .disabled(mission.isConnectedToWifi)
                            Button(action: {
                                try? mission.setWifiSsid(newWifiSsid)
                                newWifiSsid = ""
                            }) {
                                Text("update")
                            }
                            .disabled(newWifiSsid.isEmpty)
                        }
                    }
                    HStack {
                        Button(action: {
                            showWifiPassword.toggle()
                        }) {
                            Image(systemName: showWifiPassword ? "eye" : "eye.slash")
                        }
                        Text("__password__: \(showWifiPassword ? mission.wifiPassword : mission.wifiPassword.map { _ in "•" }.joined())")
                    }
                    if canEditWifi {
                        HStack {
                            Button(action: {
                                showNewWifiPassword.toggle()
                            }) {
                                Image(systemName: showNewWifiPassword ? "eye" : "eye.slash")
                            }

                            if showNewWifiPassword {
                                TextField("new wifi password", text: $newWifiPassword)
                                    .autocorrectionDisabled()
                                    .disabled(mission.isConnectedToWifi)
                            }
                            else {
                                SecureField("new wifi password", text: $newWifiPassword)
                                    .autocorrectionDisabled()
                                    .disabled(mission.isConnectedToWifi)
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
