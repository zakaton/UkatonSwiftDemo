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

#if !os(watchOS)
        Picker(selection: rotationBinding, label: EmptyView()) {
            ForEach(RotationMode.allCases) { rotationMode in
                Text(rotationMode.name)
                    .tag(rotationMode)
            }
        }
        .pickerStyle(.segmented)
#else
        VStack {}
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        var newRotationMode: RotationMode = .none

                        if isQuaternionEnabled {
                            newRotationMode = .none
                        }
                        else if isRotationRateEnabled {
                            // newRotationMode = .none
                        }
                        else {
                            newRotationMode = .quaternion
                        }

                        sensorDataConfigurations.motion[.quaternion] = 0
                        sensorDataConfigurations.motion[.rotationRate] = 0

                        switch newRotationMode {
                        case .quaternion:
                            sensorDataConfigurations.motion[.quaternion] = 20
                        case .rotationRate:
                            sensorDataConfigurations.motion[.rotationRate] = 20
                        default:
                            break
                        }

                        try? sensorDataConfigurable.setSensorDataConfigurations(sensorDataConfigurations)
                    } label: {
                        Image(systemName: isQuaternionEnabled ? "rotate.3d.fill" : "rotate.3d")
                    }
                }
            }
#endif
    }
}

#Preview {
    RotationModePicker(sensorDataConfigurable: UKMission.none, sensorDataConfigurations: .constant(.init()))
        .frame(maxWidth: 300)
}
