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

        Picker(selection: translationBinding, label: EmptyView()) {
            ForEach(TranslationMode.allCases) { translationMode in
                Text(translationMode.name)
                    .tag(translationMode)
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
    TranslationModePicker(sensorDataConfigurable: UKMission.none, sensorDataConfigurations: .constant(.init()))
        .frame(maxWidth: 300)
}
