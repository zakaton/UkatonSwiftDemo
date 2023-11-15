import SwiftUI
import UkatonKit

struct DeviceBluetoothInformationSection: View {
    let mission: UKMission

    var body: some View {
        Section {
            Text("__rssi:__ \(mission.rssi)")

        } header: {
            Text("Bluetooth Information")
                .font(.headline)
        }
    }
}

#Preview {
    List {
        DeviceBluetoothInformationSection(mission: .none)
    }
    .frame(maxWidth: 300, maxHeight: 300)
}
