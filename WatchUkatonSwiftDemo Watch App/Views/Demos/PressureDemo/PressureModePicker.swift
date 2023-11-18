import SwiftUI
import UkatonKit
import UkatonMacros

struct PressureModePicker: View {
    var sensorDataConfigurable: UKSensorDataConfigurable
    @Binding var sensorDataConfigurations: UKSensorDataConfigurations

    // MARK: - isEnabled

    var isPressureSingleByteEnabled: Bool {
        sensorDataConfigurations.pressure[.pressureSingleByte]! > 0
    }

    var isPressureDoubleByteEnabled: Bool {
        sensorDataConfigurations.pressure[.pressureDoubleByte]! > 0
    }

    var isEnabled: Bool {
        isPressureSingleByteEnabled || isPressureDoubleByteEnabled
    }

    var isMissionPair: Bool {
        guard let _ = sensorDataConfigurable as? UKMissionPair else {
            return false
        }
        return true
    }

    var systemImage: String {
        if isMissionPair {
            return isEnabled ? "shoe.2.fill" : "shoe.2"
        }
        else {
            return isEnabled ? "shoe.fill" : "shoe"
        }
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
        VStack {}
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        var newPressureMode: PressureMode = .none

                        if isEnabled {
                            newPressureMode = .none
                        }
                        else {
                            newPressureMode = .singleByte
                        }

                        sensorDataConfigurations.pressure[.pressureSingleByte] = 0
                        sensorDataConfigurations.pressure[.pressureDoubleByte] = 0

                        switch newPressureMode {
                        case .singleByte:
                            sensorDataConfigurations.pressure[.pressureSingleByte] = 20
                        case .doubleByte:
                            sensorDataConfigurations.pressure[.pressureDoubleByte] = 20
                        default:
                            break
                        }

                        try? sensorDataConfigurable.setSensorDataConfigurations(sensorDataConfigurations)
                    } label: {
                        Image(systemName: systemImage)
                    }
                    .foregroundColor(isEnabled ? .green : .primary)
                    .accessibilityLabel(isEnabled ? "disable pressure" : "enable pressure")
                }
            }
    }
}

#Preview {
    NavigationStack {
        PressureModePicker(sensorDataConfigurable: UKMission.none, sensorDataConfigurations: .constant(.init()))
    }
    .frame(maxWidth: 300)
}
