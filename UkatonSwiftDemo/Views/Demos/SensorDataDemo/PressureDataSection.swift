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

    var isWatch: Bool {
        #if os(watchOS)
        true
        #else
        false
        #endif
    }

    private let nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumIntegerDigits = 1
        nf.minimumFractionDigits = 5
        nf.maximumFractionDigits = 5
        nf.positivePrefix = " "
        nf.paddingCharacter = "0"
        nf.paddingPosition = .afterSuffix
        return nf
    }()

    var body: some View {
        let layout = isWatch ? AnyLayout(VStackLayout(alignment: .leading)) : AnyLayout(HStackLayout())

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
                    layout {
                        switch pressureDataType {
                        case .pressureSingleByte, .pressureDoubleByte:
                            Text("[\(pressureValuesData.timestamp.string)]")
                            Text(pressureValuesData.value.string)
                        case .centerOfMass:
                            Text("[\(centerOfMassData.timestamp.string)]")
                            Text(centerOfMassData.value.string)
                        case .mass:
                            Text("[\(massData.timestamp.string)]")
                            Text(nf.string(for: massData.value)!)
                        case .heelToToe:
                            Text("[\(heelToToeData.timestamp.string)]")
                            Text(nf.string(for: heelToToeData.value)!)
                        }
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
    #if os(macOS)
    .frame(maxWidth: 300)
    #endif
}
