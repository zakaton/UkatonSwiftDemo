import SwiftUI
import UkatonKit

struct DeviceWifiInformationSection: View {
    @ObservedObject private var mission: UKMission

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
        self.newShouldConnectToWifi = mission.shouldConnectToWifi
    }

    var body: some View {
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
                .toggleStyle(.switch)
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
                .font(.headline)
        }
    }
}

#Preview {
    List {
        DeviceWifiInformationSection(mission: .none)
    }
    .frame(maxWidth: 300, maxHeight: 300)
}
