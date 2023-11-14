import SwiftUI
import UkatonKit

struct MissionPair: View {
    let missionPair: UKMissionPair

    var body: some View {
        NavigationStack {
            List {
                MissionPairDemosSection(missionPair: missionPair)
            }
            .navigationTitle("Mission Pair")
            .navigationDestination(for: MissionPairDemo.self) { demo in
                demo.view(missionPair: missionPair)
            }
        }
    }
}

#Preview {
    MissionPair(missionPair: .shared)
        .frame(maxWidth: 300, maxHeight: 300)
}
