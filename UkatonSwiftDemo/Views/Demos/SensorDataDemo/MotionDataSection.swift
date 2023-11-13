import simd
import Spatial
import SwiftUI
import UkatonKit

struct MotionDataSection: View {
    @ObservedObject var mission: UKMission
    @Binding var sensorDataConfigurations: UKSensorDataConfigurations

    var sensorDataRates: [UKSensorDataRate]

    var body: some View {
        Section {
            ForEach(UKMotionDataType.allCases) { motionDataType in
                let binding = Binding<UKSensorDataRate>(
                    get: { sensorDataConfigurations.motion[motionDataType] ?? 0 },
                    set: {
                        sensorDataConfigurations.motion[motionDataType] = $0
                        try? mission.setSensorDataConfigurations(sensorDataConfigurations)
                    })

                Picker("__\(motionDataType.name.capitalized)__", selection: binding) {
                    ForEach(sensorDataRates, id: \.self) { sensorDataRate in
                        Text("\(sensorDataRate) ms")
                    }
                }

                HStack {
                    Text("Timestamp")

                    switch motionDataType {
                    case .acceleration:
                        Text(mission.sensorData.motion.acceleration.string)
                    case .gravity:
                        Text(mission.sensorData.motion.gravity.string)
                    case .linearAcceleration:
                        Text(mission.sensorData.motion.linearAcceleration.string)
                    case .magnetometer:
                        Text(mission.sensorData.motion.magnetometer.string)
                    case .rotationRate:
                        Text(mission.sensorData.motion.rotationRate.string)
                    case .quaternion:
                        Text(mission.sensorData.motion.rotation.string)
                    }
                }
                .font(Font.system(.caption, design: .monospaced))
            }
        } header: {
            Text("Motion Data")
                .font(.headline)
        }
    }
}

#Preview {
    List {
        MotionDataSection(mission: .none, sensorDataConfigurations: .constant(.init()), sensorDataRates: [0, 20, 40])
    }
    .frame(maxWidth: 300)
}
