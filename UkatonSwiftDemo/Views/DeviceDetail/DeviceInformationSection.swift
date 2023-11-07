import SwiftUI
import UkatonKit

struct DeviceInformationSection: View {
    @ObservedObject private var mission: UKMission

    @State private var newName: String = ""
    @State private var newDeviceType: UKDeviceType

    init(mission: UKMission) {
        self.mission = mission
        self.newDeviceType = mission.deviceType
    }

    var body: some View {
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
                .font(.headline)
        }
    }
}

#Preview {
    List {
        DeviceInformationSection(mission: .none)
    }
    .frame(maxWidth: 300, maxHeight: 300)
}
