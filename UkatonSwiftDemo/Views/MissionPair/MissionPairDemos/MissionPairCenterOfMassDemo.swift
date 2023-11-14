import SwiftUI
import UkatonKit

struct MissionPairCenterOfMassDemo: View {
    let missionPair: UKMissionPair

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    MissionPairCenterOfMassDemo(missionPair: .shared)
        .frame(maxWidth: 300, maxHeight: 300)
}
