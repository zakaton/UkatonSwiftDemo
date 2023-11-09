import SwiftUI
import UkatonKit

struct SensorDataDemo: View {
    @ObservedObject var mission: UKMission

    let sensorDataRates: [UKSensorDataRate] = [0, 20, 40, 80, 100]
    @State private var newSensorDataConfigurations: UKSensorDataConfigurations = .init()

    var body: some View {
        List {
            MotionDataSection(mission: mission, newSensorDataConfigurations: $newSensorDataConfigurations, sensorDataRates: sensorDataRates)
            MotionCalibrationSection(mission: mission)

            if mission.deviceType.isInsole {
                PressureDataSection(mission: mission, newSensorDataConfigurations: $newSensorDataConfigurations, sensorDataRates: sensorDataRates)
            }
        }
        .navigationTitle("Sensor Data")
    }
}

#Preview {
    SensorDataDemo(mission: .none)
        .frame(maxWidth: 360, maxHeight: 300)
}
