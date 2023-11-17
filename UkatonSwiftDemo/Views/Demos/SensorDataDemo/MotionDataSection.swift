import simd
import Spatial
import SwiftUI
import UkatonKit

struct MotionDataSection: View {
    var mission: UKMission
    @Binding var sensorDataConfigurations: UKSensorDataConfigurations

    var sensorDataRates: [UKSensorDataRate]

    @State private var accelerationData: UKAccelerationData = (.init(), 0)
    @State private var gravityData: UKGravityData = (.init(), 0)
    @State private var linearAccelerationData: UKLinearAccelerationData = (.init(), 0)
    @State private var magnetometerData: UKMagnetometerData = (.init(), 0)
    @State private var rotationRateData: UKRotationRateData = (.init(), 0)
    @State private var quaternionData: UKQuaternionData = (.init(), 0)

    var isWatch: Bool {
        #if os(watchOS)
        true
        #else
        false
        #endif
    }

    var body: some View {
        let layout = isWatch ? AnyLayout(VStackLayout(alignment: .leading)) : AnyLayout(HStackLayout())

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

                layout {
                    switch motionDataType {
                    case .acceleration:
                        Text("[\(accelerationData.timestamp.string)]")
                        Text(accelerationData.value.string)

                    case .gravity:
                        Text("[\(gravityData.timestamp.string)]")
                        Text(gravityData.value.string)
                    case .linearAcceleration:
                        Text("[\(linearAccelerationData.timestamp.string)]")
                        Text(linearAccelerationData.value.string)
                    case .magnetometer:
                        Text("[\(magnetometerData.timestamp.string)]")
                        Text(magnetometerData.value.string)
                    case .rotationRate:
                        Text("[\(rotationRateData.timestamp.string)]")
                        Text(rotationRateData.value.string)
                    case .quaternion:
                        Text("[\(quaternionData.timestamp.string)]")
                        Text(quaternionData.value.string)
                    }
                }
            }
        } header: {
            Text("Motion Data")
                .font(.headline)
        }
        .font(Font.system(.caption, design: .monospaced))
        .onReceive(mission.sensorData.motion.accelerationSubject, perform: { accelerationData = $0 })
        .onReceive(mission.sensorData.motion.gravitySubject, perform: { gravityData = $0 })
        .onReceive(mission.sensorData.motion.linearAccelerationSubject, perform: { linearAccelerationData = $0 })
        .onReceive(mission.sensorData.motion.magnetometerSubject, perform: { magnetometerData = $0 })
        .onReceive(mission.sensorData.motion.rotationRateSubject, perform: { rotationRateData = $0 })
        .onReceive(mission.sensorData.motion.quaternionSubject, perform: { quaternionData = $0 })
    }
}

#Preview {
    List {
        MotionDataSection(mission: .none, sensorDataConfigurations: .constant(.init()), sensorDataRates: [0, 20, 40])
    }
    .frame(maxWidth: 320)
}
