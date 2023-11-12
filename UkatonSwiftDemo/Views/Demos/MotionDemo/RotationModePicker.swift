import SwiftUI
import UkatonKit
import UkatonMacros

struct RotationModePicker: View {
    @ObservedObject var mission: UKMission
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

                try? mission.setSensorDataConfigurations(sensorDataConfigurations)
            })

        Picker(selection: rotationBinding, label: EmptyView()) {
            ForEach(RotationMode.allCases) { rotationMode in
                Text(rotationMode.name)
                    .tag(rotationMode)
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
    RotationModePicker(mission: .none, sensorDataConfigurations: .constant(.init()))
        .frame(maxWidth: 300)
}
