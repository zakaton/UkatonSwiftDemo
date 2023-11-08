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

    func vectorToString(_ vector: Vector3D) -> String {
        .init(format: "x: %5.3f, y: %5.3f, z: %5.3f", vector.x, vector.y, vector.z)
    }

    func rotationToString(_ rotation: Rotation3D) -> String {
        let euler = rotation.eulerAngles(order: .zxy)
        return .init(format: "p: %5.2f, y: %5.2f, r: %5.2f", euler.angles.x, euler.angles.y, euler.angles.z)
    }

    func quaternionToString(_ quaternion: Quaternion) -> String {
        return .init(format: "w: %5.3f, x: %5.3f, y: %5.3f, z: %5.3f", quaternion.vector.w, quaternion.vector.x, quaternion.vector.y, quaternion.vector.z)
    }

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
                        Text(self.vectorToString(mission.sensorData.motion.acceleration))
                    case .gravity:
                        Text(self.vectorToString(mission.sensorData.motion.gravity))
                    case .linearAcceleration:
                        Text(self.vectorToString(mission.sensorData.motion.linearAcceleration))
                    case .magnetometer:
                        Text(self.vectorToString(mission.sensorData.motion.magnetometer))
                    case .rotationRate:
                        Text(self.rotationToString(mission.sensorData.motion.rotationRate))
                    case .quaternion:
                        Text(self.rotationToString(mission.sensorData.motion.rotation))
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
