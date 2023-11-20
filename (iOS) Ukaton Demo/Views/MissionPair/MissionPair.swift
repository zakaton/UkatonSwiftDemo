import SwiftUI
import UkatonKit

struct MissionPair: View {
    @ObservedObject var missionPair: UKMissionPair = .shared

    var notConnectedMessage: String {
        if missionPair[.left] == nil && missionPair[.right] == nil {
            return "connect a left and right insole"
        }
        else {
            if missionPair[.left] == nil {
                return "connect a left insole"
            }
            else {
                return "connect a right insole"
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if missionPair.isConnected {
                    MissionPairDemosSection(missionPair: missionPair)
                }
                else {
                    HStack {
                        Spacer()
                        Text(notConnectedMessage)
                        Spacer()
                    }
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
#if os(macOS)
        .frame(maxWidth: 300, maxHeight: 300)
#endif
}
