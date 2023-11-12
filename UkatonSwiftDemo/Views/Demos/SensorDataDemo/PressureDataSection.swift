import SwiftUI
import UkatonKit

struct PressureDataSection: View {
    @ObservedObject var mission: UKMission
    @Binding var sensorDataConfigurations: UKSensorDataConfigurations

    var sensorDataRates: [UKSensorDataRate]

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
                    HStack {
                        Text("[\(mission.sensorData.pressure.timestamps[pressureDataType]!.string)]")

                        switch pressureDataType {
                        case .pressureSingleByte, .pressureDoubleByte:
                            Text(mission.sensorData.pressure.pressureValues.string)
                        case .centerOfMass:
                            Text(mission.sensorData.pressure.centerOfMass.string)
                        case .mass:
                            Text(String(format: "%6.3f", mission.sensorData.pressure.mass))
                        case .heelToToe:
                            Text(String(format: "%6.3f", mission.sensorData.pressure.heelToToe))
                        }
                    }
                    .font(Font.system(.caption, design: .monospaced))
                }
            }
        } header: {
            Text("Pressure Data")
                .font(.headline)
        }
    }
}

#Preview {
    List {
        PressureDataSection(mission: .none, sensorDataConfigurations: .constant(.init()), sensorDataRates: [0, 20, 40])
    }
    .frame(maxWidth: 300)
}
