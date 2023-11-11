import SwiftUI
import UkatonKit
import UkatonMacros

struct PressureModePicker: View {
    @ObservedObject var mission: UKMission
    @Binding var newSensorDataConfigurations: UKSensorDataConfigurations

    // MARK: - isEnabled

    var isPressureSingleByteEnabled: Bool {
        mission.sensorDataConfigurations.pressure[.pressureSingleByte]! > 0
    }

    var isPressureDoubleByteEnabled: Bool {
        mission.sensorDataConfigurations.pressure[.pressureDoubleByte]! > 0
    }

    // MARK: - mode

    @EnumName
    enum PressureMode: CaseIterable, Identifiable {
        var id: String { name }

        case none
        case singleByte
        case doubleByte
    }

    @State private var selectedPressureMode: PressureMode = .none

    var body: some View {
        let pressureBinding = Binding<PressureMode>(
            get: {
                if isPressureSingleByteEnabled {
                    return .singleByte
                }
                else if isPressureDoubleByteEnabled {
                    return .doubleByte
                }
                else {
                    return .none
                }
            },
            set: {
                newSensorDataConfigurations.pressure[.pressureSingleByte] = 0
                newSensorDataConfigurations.pressure[.pressureDoubleByte] = 0

                switch $0 {
                case .none:
                    break
                case .singleByte:
                    newSensorDataConfigurations.pressure[.pressureSingleByte] = 20
                case .doubleByte:
                    newSensorDataConfigurations.pressure[.pressureDoubleByte] = 20
                }

                try? mission.setSensorDataConfigurations(newSensorDataConfigurations)
            })

        Picker(selection: pressureBinding, label: EmptyView()) {
            ForEach(PressureMode.allCases) { pressureMode in
                Text(pressureMode.name)
                    .tag(pressureMode)
            }
        }
        .modify {
            #if !os(watchOS)
            $0.pickerStyle(.segmented)
            #endif
        }
    }
}

#Preview {
    PressureModePicker(mission: .none, newSensorDataConfigurations: .constant(.init()))
        .frame(maxWidth: 300)
}
