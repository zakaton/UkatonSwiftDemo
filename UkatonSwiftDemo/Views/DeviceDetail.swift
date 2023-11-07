import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros

@StaticLogger
struct DeviceDetail: View {
    @ObservedObject var mission: UKMission

    var body: some View {
        List {
            DeviceInformationSection(mission: mission)
            DeviceWifiInformationSection(mission: mission)
        }
        .navigationTitle(mission.name)
    }
}

#Preview {
    DeviceDetail(mission: .none)
        .frame(maxWidth: 300, maxHeight: 300)
}
