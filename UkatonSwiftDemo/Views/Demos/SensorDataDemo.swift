import SwiftUI
import UkatonKit
import UkatonMacros

// TODO: - FILL

struct SensorDataDemo: View {
    @ObservedObject private var mission: UKMission

    let sensorDataRates: [UKSensorDataRate] = [0, 20, 40, 80, 100]
    @State private var newSensorDataConfigurations: UKSensorDataConfigurations = .init() {
        didSet {
            try? mission.setSensorDataConfigurations(newSensorDataConfigurations)
        }
    }

    init(mission: UKMission) {
        self.mission = mission
    }

    var body: some View {
        List {
            Section {
                ForEach(UKMotionDataType.allCases) { motionDataType in
                    let binding = Binding<UKSensorDataRate>(
                        get: { mission.sensorDataConfigurations.motion[motionDataType] ?? 0 },
                        set: {
                            self.newSensorDataConfigurations.motion[motionDataType] = $0
                        })

                    Picker("__\(motionDataType.name)__", selection: binding) {
                        ForEach(sensorDataRates, id: \.self) { sensorDataRate in
                            Text(String(sensorDataRate))
                        }
                    }
                }
            } header: {
                Text("Motion Data")
                    .font(.headline)
            }

            if true || mission.deviceType.isInsole {
                Section {
                    ForEach(UKPressureDataType.allCases) { pressureDataType in
                        let binding = Binding<UKSensorDataRate>(
                            get: { mission.sensorDataConfigurations.pressure[pressureDataType] ?? 0 },
                            set: {
                                self.newSensorDataConfigurations.pressure[pressureDataType] = $0
                            })

                        Picker("__\(pressureDataType.name)__", selection: binding) {
                            ForEach(sensorDataRates, id: \.self) { sensorDataRate in
                                Text(String(sensorDataRate))
                            }
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
