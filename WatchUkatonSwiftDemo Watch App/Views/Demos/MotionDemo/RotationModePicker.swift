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

    var isEnabled: Bool {
        isQuaternionEnabled || isRotationRateEnabled
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
                        Image(systemName: isEnabled ? "rotate.3d.fill" : "rotate.3d")
                    }
                    .foregroundColor(isEnabled ? .green : .primary)
                    .accessibilityLabel(isEnabled ? "disable rotation" : "enable rotation")
                }
            }
    }
}

#Preview {
    NavigationStack {
        RotationModePicker(sensorDataConfigurable: UKMission.none, sensorDataConfigurations: .constant(.init()))
    }
    .frame(maxWidth: 300)
}
