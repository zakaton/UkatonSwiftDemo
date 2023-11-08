import simd
import Spatial
import SwiftUI
import UkatonKit

struct MotionDataSection: View {
    @ObservedObject var mission: UKMission
    @Binding var newSensorDataConfigurations: UKSensorDataConfigurations {
        didSet {
            try? mission.setSensorDataConfigurations(newSensorDataConfigurations)
        }
    }

    var sensorDataRates: [UKSensorDataRate]

    var body: some View {
        Section {
            ForEach(UKMotionDataType.allCases) { motionDataType in
                let binding = Binding<UKSensorDataRate>(
                    get: { mission.sensorDataConfigurations.motion[motionDataType] ?? 0 },
                    set: {
                        self.newSensorDataConfigurations.motion[motionDataType] = $0
                    })

                Picker("__\(motionDataType.name.capitalized)__", selection: binding) {
                    ForEach(sensorDataRates, id: \.self) { sensorDataRate in
                        Text("\(sensorDataRate) ms")
                    }
                }

                HStack {
                    Text("[\(mission.sensorData.motion.timestamps[motionDataType]!.string)]")

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
        MotionDataSection(mission: .none, newSensorDataConfigurations: .constant(.init()), sensorDataRates: [0, 20, 40])
    }
    .frame(maxWidth: 300)
}
