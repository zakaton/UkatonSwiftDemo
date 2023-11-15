import SwiftUI
import UkatonKit

struct PressureDemo: View {
    var mission: UKMission

    @State private var sensorDataConfigurations: UKSensorDataConfigurations = .init()

    var body: some View {
        VStack {
            PressureView(mission: mission)
            PressureModePicker(sensorDataConfigurable: mission, sensorDataConfigurations: $sensorDataConfigurations)
        }
        .navigationTitle("Pressure")
        .onReceive(mission.sensorDataConfigurationsSubject, perform: {
            sensorDataConfigurations = $0
        })
        .onDisappear {
            try? mission.clearSensorDataConfigurations()
        }
    }
}

#Preview {
    NavigationStack { PressureDemo(mission: .none) }
        .frame(maxWidth: 360, maxHeight: 300)
}
