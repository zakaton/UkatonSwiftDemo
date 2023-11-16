import SwiftUI
import UkatonKit

struct MissionPair: View {
    @ObservedObject var missionPair: UKMissionPair = .shared

    var body: some View {
        NavigationStack {
            List {
                if missionPair.isConnected {
                    MissionPairDemosSection(missionPair: missionPair)
                }
                else {
                    Text("connect a left and right insole")
                }
            }
            .navigationTitle("Mission Pair")
            .navigationDestination(for: MissionPairDemo.self) { demo in
                demo.view(missionPair: missionPair)
            }
        }
    }
}

#Preview {
    MissionPair()
        .frame(maxWidth: 300, maxHeight: 300)
}
