import SwiftUI
import UkatonKit

struct MissionPairMotionDemo: View {
    let missionPair: UKMissionPair
    var body: some View {
        HStack {
            ForEach(UKInsoleSide.allCases) { side in
                if let mission = missionPair[side] {
                    MotionDemo(mission: mission)
                }
            }
        }
    }
}

#Preview {
    MissionPairMotionDemo(missionPair: .shared)
        .frame(maxWidth: 360, maxHeight: 300)
}
