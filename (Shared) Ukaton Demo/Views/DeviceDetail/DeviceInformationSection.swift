import SwiftUI
import UkatonKit

struct DeviceInformationSection: View {
    @ObservedObject private var mission: UKMission

    @State private var newName: String = ""
    @State private var newDeviceType: UKDeviceType

    @State private var batteryLevel: UKBatteryLevel = .zero

    init(mission: UKMission) {
        self.mission = mission
        self.newDeviceType = mission.deviceType
    }

    var shouldEdit: Bool {
        !isWatch && !isTv
    }

    var body: some View {
        Section {
            HStack {
                Text("__name:__")
                Text("\(mission.name)")
                #if os(iOS)
                    .textSelection(.enabled)
                #endif
            }
            if shouldEdit {
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
            }

            Picker("__device type__", selection: $newDeviceType) {
                ForEach(UKDeviceType.allCases) { deviceType in
                    Text(deviceType.name)
                }
            }
            .onChange(of: newDeviceType) {
                try? mission.setDeviceType(newDeviceType)
            }

            if let connectionType = mission.connectionType {
                Text("__connection type:__ \(connectionType.name)")
            }

            Text("__battery level:__ \(String(batteryLevel))%")
                .onReceive(mission.batteryLevelSubject, perform: { batteryLevel = $0
                })
        } header: {
            Text("Device Information")
                .font(.headline)
        }
    }
}

#Preview {
    List {
        DeviceInformationSection(mission: .none)
    }
    #if os(macOS)
    .frame(maxWidth: 300, maxHeight: 300)
    #endif
}
