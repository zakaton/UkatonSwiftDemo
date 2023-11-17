import SwiftUI
import UkatonKit

struct PressureDataSection: View {
    var mission: UKMission
    @Binding var sensorDataConfigurations: UKSensorDataConfigurations

    var sensorDataRates: [UKSensorDataRate]

    @State private var pressureValuesData: UKPressureValuesData = (.init(), 0)
    @State private var centerOfMassData: UKCenterOfMassData = (.init(), 0)
    @State private var massData: UKMassData = (.zero, 0)
    @State private var heelToToeData: UKHeelToToeData = (.zero, 0)

    var body: some View {
        Section {
            ForEach(UKPressureDataType.allCases) { pressureDataType in
                let binding = Binding<UKSensorDataRate>(
                    get: { sensorDataConfigurations.pressure[pressureDataType] ?? 0 },
                    set: {
                        sensorDataConfigurations.pressure[pressureDataType] = $0
                        try? mission.setSensorDataConfigurations(sensorDataConfigurations)
                    })

                Picker("__\(pressureDataType.name.capitalized)__", selection: binding) {
                    ForEach(sensorDataRates, id: \.self) { sensorDataRate in
                        Text("\(sensorDataRate) ms")
                    }
                }

                if !pressureDataType.isPressure || mission.sensorData.pressure.pressureValues.latestPressureDataType == pressureDataType {
                    switch pressureDataType {
                    case .pressureSingleByte, .pressureDoubleByte:
                        Text("[\(pressureValuesData.timestamp.string)]")
                        Text(pressureValuesData.value.string)
                    case .centerOfMass:
                        Text("[\(centerOfMassData.timestamp.string)]")
                        Text(centerOfMassData.value.string)
                    case .mass:
                        Text("[\(massData.timestamp.string)]")
                        Text(String(massData.value))
                    case .heelToToe:
                        Text("[\(heelToToeData.timestamp.string)]")
                        Text(String(heelToToeData.value))
                    }
                }
            }

        } header: {
            Text("Pressure Data")
                .font(.headline)
        }
        .font(Font.system(.caption, design: .monospaced))
        .onReceive(mission.sensorData.pressure.pressureValuesSubject, perform: { pressureValuesData = $0
        })
        .onReceive(mission.sensorData.pressure.massSubject, perform: { massData = $0
        })
        .onReceive(mission.sensorData.pressure.centerOfMassSubject, perform: { centerOfMassData = $0
        })
        .onReceive(mission.sensorData.pressure.heelToToeSubject, perform: { heelToToeData = $0
        })
    }
}

#Preview {
    List {
        PressureDataSection(mission: .none, sensorDataConfigurations: .constant(.init()), sensorDataRates: [0, 20, 40])
    }
    .frame(maxWidth: 300)
}
