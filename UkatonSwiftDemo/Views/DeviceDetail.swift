import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros

@StaticLogger
struct DeviceDetail: View {
    @ObservedObject var mission: UKMission

    var name: String {
        mission.name ?? "undefined device"
    }

    @State private var newName: String = ""

    var type: String {
        mission.deviceType?.name ?? "unknown type"
    }

    @State private var newDeviceType: UKDeviceType

    init(mission: UKMission) {
        self.mission = mission
        self.newDeviceType = mission.deviceType ?? .motionModule
    }

    var body: some View {
        List {
            Section {
                Text("__name:__ \(name)")
                HStack {
                    TextField("new name", text: $newName)
                    Button(action: {
                        try? mission.setName(newName: newName)
                        newName = ""
                    }) {
                        Image(systemName: "arrow.up.circle")
                            .accessibilityLabel("Update name")
                    }
                    .disabled(newName.isEmpty)
                }

                Text("__type:__ \(type)")
                Picker("type", selection: $newDeviceType) {
                    ForEach(UKDeviceType.allCases) { deviceType in
                        Text(deviceType.name)
                    }
                }
                .onChange(of: newDeviceType) {
                    try? mission.setDeviceType(newDeviceType: newDeviceType)
                }
            } header: {
                Text("Device Information")
            }
        }
        .navigationTitle(name)
    }
}

#Preview {
    DeviceDetail(mission: .none)
        .frame(maxWidth: 300, maxHeight: 300)
}
