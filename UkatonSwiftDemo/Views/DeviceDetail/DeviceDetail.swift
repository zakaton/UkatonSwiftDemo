import SwiftUI
import UkatonKit

struct DeviceDetail: View {
    var mission: UKMission

    var body: some View {
        List {
            DeviceInformationSection(mission: mission)
            if mission.connectionType == .bluetooth {
                DeviceBluetoothInformationSection(mission: mission)
            }
            DeviceWifiInformationSection(mission: mission)
            DeviceDemosSection(mission: mission)
        }
        .navigationTitle(mission.name)
        .navigationDestination(for: DeviceDemo.self) { demo in
            demo.view(mission: mission)
        }
    }
}

#Preview {
    NavigationStack {
        DeviceDetail(mission: .none)
    }
    .frame(maxWidth: 300, maxHeight: 300)
}
