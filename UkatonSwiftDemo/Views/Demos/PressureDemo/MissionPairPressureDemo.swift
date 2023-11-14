import SwiftUI
import UkatonKit

struct MissionPairPressureDemo: View {
    let missionPair: UKMissionPair
    var body: some View {
        HStack {
            ForEach(UKInsoleSide.allCases) { side in
                if let mission = missionPair[side] {
                    PressureDemo(mission: mission)
                }
            }
        }
    }
}

#Preview {
    MissionPairPressureDemo(missionPair: .shared)
        .frame(maxWidth: 360, maxHeight: 300)
}
