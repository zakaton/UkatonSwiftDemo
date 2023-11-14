import SwiftUI
import UkatonKit

struct MissionPairPressureDemo: View {
    let missionPair: UKMissionPair
    var body: some View {
        HStack {
            PressureDemo(mission: missionPair[.left] ?? .none)
            PressureDemo(mission: missionPair[.right] ?? .none)
        }
    }
}

#Preview {
    MissionPairPressureDemo(missionPair: .shared)
        .frame(maxWidth: 400, maxHeight: 300)
}
