import SwiftUI
import UkatonKit

struct DeviceDetail: View {
    @ObservedObject var mission: UKMission

    var body: some View {
        List {
            DeviceInformationSection(mission: mission)
            DeviceWifiInformationSection(mission: mission)
            DeviceDemosSection(mission: mission)
        }
        .navigationTitle(mission.name)
        .navigationDestination(for: DeviceDemo.self) { deviceDemo in
            deviceDemo.view(mission: mission)
        }
    }
}

#Preview {
    DeviceDetail(mission: .none)
        .frame(maxWidth: 300, maxHeight: 300)
}