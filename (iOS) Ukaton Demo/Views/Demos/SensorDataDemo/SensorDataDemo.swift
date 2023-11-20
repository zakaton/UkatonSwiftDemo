import SwiftUI
import UkatonKit

struct SensorDataDemo: View {
    var mission: UKMission

    let sensorDataRates: [UKSensorDataRate] = [0, 20, 40, 80, 100]
    @State private var sensorDataConfigurations: UKSensorDataConfigurations = .init()

    var body: some View {
        List {
            MotionDataSection(mission: mission, sensorDataConfigurations: $sensorDataConfigurations, sensorDataRates: sensorDataRates)
            MotionCalibrationSection(mission: mission)

            if mission.deviceType.isInsole {
                PressureDataSection(mission: mission, sensorDataConfigurations: $sensorDataConfigurations, sensorDataRates: sensorDataRates)
            }
        }
        .onReceive(mission.sensorDataConfigurationsSubject, perform: {
            sensorDataConfigurations = $0
        })
        .onDisappear {
            try? mission.clearSensorDataConfigurations()
        }
        .navigationTitle("Sensor Data")
    }
}

#Preview {
    NavigationStack { SensorDataDemo(mission: .none) }
    #if os(macOS)
        .frame(maxWidth: 360, maxHeight: 300)
    #endif
}
