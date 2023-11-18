import SwiftUI
import UkatonKit

struct MissionPairPressureDemo: View {
    let missionPair: UKMissionPair

    @State private var sensorDataConfigurations: UKSensorDataConfigurations = .init()

    var body: some View {
        VStack {
            HStack {
                PressureView(mission: missionPair[.left] ?? .none)
                PressureView(mission: missionPair[.right] ?? .none)
            }
            PressureModePicker(sensorDataConfigurable: missionPair, sensorDataConfigurations: $sensorDataConfigurations)
        }
        .navigationTitle("Pressure")
        .onReceive(missionPair.sensorDataConfigurationsSubject, perform: {
            sensorDataConfigurations = $0
        })
        .onDisappear {
            try? missionPair.clearSensorDataConfigurations()
        }
    }
}

#Preview {
    NavigationStack {
        MissionPairPressureDemo(missionPair: .shared)
    }
    .frame(maxWidth: 400, maxHeight: 300)
}
