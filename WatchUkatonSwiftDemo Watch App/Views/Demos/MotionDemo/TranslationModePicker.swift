import SwiftUI
import UkatonKit
import UkatonMacros

struct TranslationModePicker: View {
    var sensorDataConfigurable: UKSensorDataConfigurable
    @Binding var sensorDataConfigurations: UKSensorDataConfigurations

    // MARK: isEnabled

    var isLinearAccelerationEnabled: Bool {
        sensorDataConfigurations.motion[.linearAcceleration]! > 0
    }

    var isAccelerationEnabled: Bool {
        sensorDataConfigurations.motion[.acceleration]! > 0
    }

    var isEnabled: Bool {
        isLinearAccelerationEnabled || isAccelerationEnabled
    }

    // MARK: - mode

    @EnumName
    enum TranslationMode: CaseIterable, Identifiable {
        var id: String { name }

        case none
        case linearAcceleration
        case acceleration
    }

    var body: some View {
        VStack {}
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        var newTranslationMode: TranslationMode = .none

                        if isAccelerationEnabled {
                            // newTranslationMode = .linearAcceleration
                        }
                        else if isLinearAccelerationEnabled {
                            newTranslationMode = .none
                        }
                        else {
                            newTranslationMode = .linearAcceleration
                        }

                        sensorDataConfigurations.motion[.linearAcceleration] = 0
                        sensorDataConfigurations.motion[.acceleration] = 0

                        switch newTranslationMode {
                        case .acceleration:
                            sensorDataConfigurations.motion[.acceleration] = 20
                        case .linearAcceleration:
                            sensorDataConfigurations.motion[.linearAcceleration] = 20
                        default:
                            break
                        }

                        try? sensorDataConfigurable.setSensorDataConfigurations(sensorDataConfigurations)
                    } label: {
                        Image(systemName: "move.3d")
                    }
                    .foregroundColor(isEnabled ? .green : .primary)
                    .accessibilityLabel(isEnabled ? "disable translation" : "enable translation")
                }
            }
    }
}

#Preview {
    NavigationStack {
        TranslationModePicker(sensorDataConfigurable: UKMission.none, sensorDataConfigurations: .constant(.init()))
    }
    .frame(maxWidth: 300)
}
