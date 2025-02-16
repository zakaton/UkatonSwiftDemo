import SwiftUI
import UkatonKit
import UkatonMacros

struct RotationModePicker: View {
    var sensorDataConfigurable: UKSensorDataConfigurable
    @Binding var sensorDataConfigurations: UKSensorDataConfigurations

    // MARK: - isEnabled

    var isQuaternionEnabled: Bool {
        sensorDataConfigurations.motion[.quaternion]! > 0
    }

    var isRotationRateEnabled: Bool {
        sensorDataConfigurations.motion[.rotationRate]! > 0
    }

    // MARK: - mode

    @EnumName
    enum RotationMode: CaseIterable, Identifiable {
        var id: String { name }

        case none
        case quaternion
        case rotationRate
    }

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
                sensorDataConfigurations.motion[.quaternion] = 0
                sensorDataConfigurations.motion[.rotationRate] = 0

                switch $0 {
                case .none:
                    break
                case .quaternion:
                    sensorDataConfigurations.motion[.quaternion] = 20
                case .rotationRate:
                    sensorDataConfigurations.motion[.rotationRate] = 20
                }

                try? sensorDataConfigurable.setSensorDataConfigurations(sensorDataConfigurations)
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
    NavigationStack {
        RotationModePicker(sensorDataConfigurable: UKMission.none, sensorDataConfigurations: .constant(.init()))
    }
    #if os(macOS)
    .frame(maxWidth: 300)
    #endif
}
