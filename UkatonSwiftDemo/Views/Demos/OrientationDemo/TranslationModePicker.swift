import SwiftUI
import UkatonKit
import UkatonMacros

struct TranslationModePicker: View {
    @ObservedObject var mission: UKMission
    @Binding var newSensorDataConfigurations: UKSensorDataConfigurations

    // MARK: isEnabled

    var isLinearAccelerationEnabled: Bool {
        mission.sensorDataConfigurations.motion[.linearAcceleration]! > 0
    }

    var isAccelerationEnabled: Bool {
        mission.sensorDataConfigurations.motion[.acceleration]! > 0
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
                newSensorDataConfigurations.motion[.acceleration] = 0
                newSensorDataConfigurations.motion[.linearAcceleration] = 0

                switch $0 {
                case .none:
                    break
                case .acceleration:
                    newSensorDataConfigurations.motion[.acceleration] = 20
                case .linearAcceleration:
                    newSensorDataConfigurations.motion[.linearAcceleration] = 20
                }

                try? mission.setSensorDataConfigurations(newSensorDataConfigurations)
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
    TranslationModePicker(mission: .none, newSensorDataConfigurations: .constant(.init()))
        .frame(maxWidth: 300)
}
