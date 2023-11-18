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

    // MARK: - enum

    @EnumName
    enum TranslationMode: CaseIterable, Identifiable {
        var id: String { name }

        case none
        case linearAcceleration
        case acceleration
    }

    @State private var selectedTranslationMode: TranslationMode = .none

    var body: some View {
        let translationBinding = Binding<TranslationMode>(
            get: {
                if isAccelerationEnabled {
                    return .acceleration
                }
                else if isLinearAccelerationEnabled {
                    return .linearAcceleration
                }
                else {
                    return .none
                }
            },
            set: {
                sensorDataConfigurations.motion[.acceleration] = 0
                sensorDataConfigurations.motion[.linearAcceleration] = 0

                switch $0 {
                case .none:
                    break
                case .acceleration:
                    sensorDataConfigurations.motion[.acceleration] = 20
                case .linearAcceleration:
                    sensorDataConfigurations.motion[.linearAcceleration] = 20
                }

                try? sensorDataConfigurable.setSensorDataConfigurations(sensorDataConfigurations)
            })

        #if !os(watchOS)
        Picker(selection: translationBinding, label: EmptyView()) {
            ForEach(TranslationMode.allCases) { translationMode in
                Text(translationMode.name)
                    .tag(translationMode)
            }
        }
        #else
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
                        Image(systemName: isLinearAccelerationEnabled ? "move.3d" : "scale.3d")
                    }
                }
            }
        #endif
    }
}

#Preview {
    TranslationModePicker(sensorDataConfigurable: UKMission.none, sensorDataConfigurations: .constant(.init()))
        .frame(maxWidth: 300)
}
