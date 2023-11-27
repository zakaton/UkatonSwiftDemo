import Foundation
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

    var shouldEditWifi: Bool {
        !isWatch && !isTv
    }

    @State private var newWifiSsid: String = ""
    @State private var newWifiPassword: String = ""
    @State private var showWifiPassword: Bool = false
    @State private var showNewWifiPassword: Bool = false
    @State private var shouldConnectToWifi: Bool

    @State private var didCopyIpAddressToClipboard: Bool = false

    init(mission: UKMission) {
        self.mission = mission
        self.shouldConnectToWifi = mission.shouldConnectToWifi
    }

    var body: some View {
        Section {
            if canEditWifi {
                Toggle(isOn: $shouldConnectToWifi) {
                    Text("Connect to wifi?")
                        .bold()
                }
                .onChange(of: shouldConnectToWifi) {
                    newWifiSsid = ""
                    newWifiPassword = ""
                    try? mission.setWifiShouldConnect(shouldConnectToWifi)
                }
                #if !os(tvOS)
                .toggleStyle(.switch)
                #endif
            }
            Text("__connected?__ \(String(mission.isConnectedToWifi))")

            if mission.isConnectedToWifi, let ipAddress = mission.ipAddress {
                HStack {
                    Text("__ip address__: \(ipAddress)")
                    #if os(iOS)
                    Button(action: {
                        let pasteboard = UIPasteboard.general
                        pasteboard.string = ipAddress
                        print("copied!")
                        didCopyIpAddressToClipboard = true
                    }) {
                        if didCopyIpAddressToClipboard {
                            Label("copied!", systemImage: "list.clipboard")
                                .labelStyle(LabelSpacing(spacing: 4))
                        }
                        else {
                            Label("", systemImage: "clipboard")
                                .labelStyle(LabelSpacing(spacing: 4))
                        }
                    }
                    .onReceive(mission.$ipAddress.dropFirst(), perform: { _ in
                        didCopyIpAddressToClipboard = false
                    })
                    .onReceive(mission.$isConnectedToWifi.dropFirst(), perform: { _ in
                        didCopyIpAddressToClipboard = false
                    })
                    #endif
                }
            }

            if !requiresWifi {
                Text("__ssid__: \(mission.wifiSsid)")
                if canEditWifi, shouldEditWifi {
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
                if canEditWifi, shouldEditWifi {
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
    #if os(macOS)
    .frame(maxWidth: 300, maxHeight: 300)
    #endif
}
