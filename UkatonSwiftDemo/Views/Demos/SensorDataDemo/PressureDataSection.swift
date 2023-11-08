import SwiftUI
import UkatonKit

struct PressureDataSection: View {
    @ObservedObject var mission: UKMission
    @Binding var newSensorDataConfigurations: UKSensorDataConfigurations {
        didSet {
            try? mission.setSensorDataConfigurations(newSensorDataConfigurations)
        }
    }

    var sensorDataRates: [UKSensorDataRate]

    var body: some View {
        Section {
            ForEach(UKPressureDataType.allCases) { pressureDataType in
                let binding = Binding<UKSensorDataRate>(
                    get: { mission.sensorDataConfigurations.pressure[pressureDataType] ?? 0 },
                    set: {
                        self.newSensorDataConfigurations.pressure[pressureDataType] = $0
                    })

                Picker("__\(pressureDataType.name.capitalized)__", selection: binding) {
                    ForEach(sensorDataRates, id: \.self) { sensorDataRate in
                        Text("\(sensorDataRate) ms")
                    }
                }

                HStack {
                    Text("[\(mission.sensorData.pressure.timestamps[pressureDataType]!.string)]")

                    switch pressureDataType {
                    default:
                        Text("lol")
                    }
                }
                .font(Font.system(.caption, design: .monospaced))
            }
        } header: {
            Text("Pressure Data")
                .font(.headline)
        }
    }
}

#Preview {
    List {
        PressureDataSection(mission: .none, newSensorDataConfigurations: .constant(.init()), sensorDataRates: [0, 20, 40])
    }
    .frame(maxWidth: 300)
}
