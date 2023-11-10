import SwiftUI
import UkatonKit
import UkatonMacros

struct RotationModePicker: View {
    @ObservedObject var mission: UKMission
    @Binding var newSensorDataConfigurations: UKSensorDataConfigurations

    // MARK: - isEnabled

    var isQuaternionEnabled: Bool {
        mission.sensorDataConfigurations.motion[.quaternion]! > 0
    }

    var isRotationRateEnabled: Bool {
        mission.sensorDataConfigurations.motion[.rotationRate]! > 0
    }

    // MARK: - mode

    @EnumName
    enum RotationMode: CaseIterable, Identifiable {
        var id: String { name }

        case none
        case quaternion
        case rotationRate
    }

    @State private var selectedRotationMode: RotationMode = .none

    var body: some View {
        let rotationBinding = Binding<RotationMode>(
            get: {
                if isQuaternionEnabled {
                    return .quaternion
                }
                else if isRotationRateEnabled {
                    return .rotationRate
                }
                else {
                    return .none
                }
            },
            set: {
                newSensorDataConfigurations.motion[.quaternion] = 0
                newSensorDataConfigurations.motion[.rotationRate] = 0

                switch $0 {
                case .none:
                    break
                case .quaternion:
                    newSensorDataConfigurations.motion[.quaternion] = 20
                case .rotationRate:
                    newSensorDataConfigurations.motion[.rotationRate] = 20
                }

                try? mission.setSensorDataConfigurations(newSensorDataConfigurations)
            })

        Picker(selection: rotationBinding, label: EmptyView()) {
            ForEach(RotationMode.allCases) { rotationMode in
                Text(rotationMode.name)
                    .tag(rotationMode)
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    RotationModePicker(mission: .none, newSensorDataConfigurations: .constant(.init()))
        .frame(maxWidth: 300)
}
