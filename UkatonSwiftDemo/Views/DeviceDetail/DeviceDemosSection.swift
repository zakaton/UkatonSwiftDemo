import SwiftUI
import UkatonKit
import UkatonMacros

@EnumName
enum DeviceDemo: CaseIterable, Identifiable {
    public var id: Self { self }

    case sensorData
    case motion
    case pressure
    case vibration

    var requiresPressure: Bool {
        switch self {
        case .pressure:
            true
        default:
            false
        }
    }

    @ViewBuilder func view(mission: UKMission) -> some View {
        switch self {
        case .sensorData: SensorDataDemo(mission: mission)
        case .motion: MotionDemo(mission: mission)
        case .pressure: PressureDemo(mission: mission)
        case .vibration: VibrationDemo(mission: mission)
        }
    }
}

struct DeviceDemosSection: View {
    @ObservedObject var mission: UKMission

    var body: some View {
        Section {
            ForEach(DeviceDemo.allCases) { demo in
                if !demo.requiresPressure || mission.deviceType.isInsole {
                    HStack {
                        NavigationLink(demo.name, value: demo)
                    }
                }
            }

        } header: {
            Text("Demos")
                .font(.headline)
        }
    }
}

#Preview {
    NavigationStack {
        List {
            DeviceDemosSection(mission: .none)
        }
        .navigationDestination(for: DeviceDemo.self) { deviceDemo in
            deviceDemo.view(mission: .none)
        }
    }
    .frame(maxWidth: 320, maxHeight: 300)
}
