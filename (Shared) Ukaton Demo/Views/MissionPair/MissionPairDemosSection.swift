import SwiftUI
import UkatonKit
import UkatonMacros

@EnumName
enum MissionPairDemo: CaseIterable, Identifiable {
    public var id: Self { self }

    case motion
    case pressure
    case centerOfMass
    case balance
    case vibration

    var worksWithWatch: Bool {
        switch self {
        case .motion:
            false
        default:
            true
        }
    }

    @ViewBuilder func view(missionPair: UKMissionPair) -> some View {
        switch self {
        case .motion: MissionPairMotionDemo(missionPair: missionPair)
        case .pressure: MissionPairPressureDemo(missionPair: missionPair)
        case .centerOfMass: CenterOfMassDemo(centerOfMassProvider: missionPair)
        case .balance: BalanceDemo(centerOfMassProvider: missionPair)
        case .vibration:
            VibrationDemo(vibratable: missionPair)
        }
    }
}

struct MissionPairDemosSection: View {
    let missionPair: UKMissionPair

    var body: some View {
        Section {
            ForEach(MissionPairDemo.allCases.filter {
                !isWatch || $0.worksWithWatch
            }) { demo in
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
    #if os(macOS)
    .frame(maxWidth: 320, maxHeight: 300)
    #endif
}
