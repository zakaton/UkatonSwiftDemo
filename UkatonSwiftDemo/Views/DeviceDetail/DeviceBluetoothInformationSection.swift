import SwiftUI
import UkatonKit

struct DeviceBluetoothInformationSection: View {
    let mission: UKMission

    @State private var rssi: Int = 0
    @State private var isReadingRSSI: Bool = false

    var body: some View {
        Section {
            Text("__rssi:__ \(rssi)")
                .onReceive(mission.rssiSubject, perform: { rssi = $0 })
            Button(action: {
                mission.toggleReadingRSSI()
            }) {
                if isReadingRSSI {
                    Text("stop reading rssi")
                }
                else {
                    Text("start reading rssi")
                }
            }
            .onReceive(mission.isReadingRSSISubject, perform: { isReadingRSSI = $0 })

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
