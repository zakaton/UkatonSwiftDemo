import SwiftUI
import UkatonKit
import UkatonMacros

@EnumName
enum MissionPairDemo: CaseIterable, Identifiable {
    public var id: Self { self }

    case motion
    case pressure
    case centerOfMass
    case vibration

    @ViewBuilder func view(missionPair: UKMissionPair) -> some View {
        switch self {
        case .motion: MissionPairMotionDemo(missionPair: missionPair)
        case .pressure: MissionPairPressureDemo(missionPair: missionPair)
        case .centerOfMass: MissionPairCenterOfMassDemo(missionPair: missionPair)
        case .vibration:
            VibrationDemo(vibratable: missionPair)
        }
    }
}

struct MissionPairDemosSection: View {
    let missionPair: UKMissionPair

    var body: some View {
        Section {
            ForEach(MissionPairDemo.allCases) { demo in
                HStack {
                    NavigationLink(demo.name, value: demo)
                }
            }

        } header: {
            Text("Demos")
                .font(.headline)
        }
    }
}

#Preview {
    NavigationStack {
        List {
            MissionPairDemosSection(missionPair: .shared)
        }
        .navigationDestination(for: MissionPairDemo.self) { demo in
            demo.view(missionPair: .shared)
        }
    }
    .frame(maxWidth: 320, maxHeight: 300)
}
