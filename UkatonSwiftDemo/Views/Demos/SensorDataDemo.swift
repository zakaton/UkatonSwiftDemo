import SwiftUI
import UkatonKit
import UkatonMacros

@EnumName
enum SensorDataRate: UInt16, CaseIterable, Identifiable {
    var id: UInt16 { rawValue }

    case _0 = 0
    case _20 = 20
}

struct SensorDataDemo: View {
    @ObservedObject private var mission: UKMission

    let sensorDataRates: [UKSensorDataRate] = [0, 20, 40]

    init(mission: UKMission) {
        self.mission = mission
        print(mission.sensorDataConfigurations.motion)
    }

    var body: some View {
        List {
            Section {
                ForEach(UKMotionDataType.allCases) { motionDataType in
                    Picker("__\(motionDataType.name)__", selection: $mission.sensorDataConfigurations.motion[motionDataType]) {
                        ForEach(SensorDataRate.allCases) { sensorDataRate in
                            Text(sensorDataRate.name)
                        }
                    }
                    .onChange(of: mission.sensorDataConfigurations.motion[motionDataType]) {
                        print(motionDataType)
                    }
                }
            } header: {
                Text("Motion Data")
                    .font(.headline)
            }

            if true || mission.deviceType.isInsole {
                Section {
                    ForEach(UKPressureDataType.allCases) { pressureDataType in
                        Picker("__\(pressureDataType.name)__", selection: $mission.sensorDataConfigurations.pressure[pressureDataType]) {
                            ForEach(SensorDataRate.allCases) { sensorDataRate in
                                Text(sensorDataRate.name)
                            }
                        }
                        .onChange(of: mission.sensorDataConfigurations.pressure[pressureDataType]) {
                            print(pressureDataType)
                        }
                    }
                } header: {
                    Text("Pressure Data")
                        .font(.headline)
                }
            }
        }
        .navigationTitle("Sensor Data")
    }
}

#Preview {
    SensorDataDemo(mission: .none)
        .frame(maxWidth: 300, maxHeight: 300)
}
