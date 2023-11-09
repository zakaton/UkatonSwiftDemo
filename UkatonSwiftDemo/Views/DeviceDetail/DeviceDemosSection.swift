import SwiftUI
import UkatonKit
import UkatonMacros

@EnumName
enum DeviceDemo: CaseIterable, Identifiable {
    public var id: Self { self }

    case sensorData
    case orientation
    case pressure
    case haptics

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
        case .orientation: OrientationDemo(mission: mission)
        case .pressure: PressureDemo(mission: mission)
        case .haptics: HapticsDemo(mission: mission)
        }
    }
}

struct DeviceDemosSection: View {
    @ObservedObject private var mission: UKMission

    init(mission: UKMission) {
        self.mission = mission
    }

    var body: some View {
        Section {
            ForEach(DeviceDemo.allCases) { deviceDemo in
                if !deviceDemo.requiresPressure || mission.deviceType.isInsole {
                    HStack {
                        NavigationLink(deviceDemo.name, value: deviceDemo)
                        Spacer()
                    }
                }
            }

        } header: {
            Text("Demos")
                .font(.headline)
        }
    }
}

struct DeviceDemosSection_Preview: PreviewProvider {
    private static var mission: UKMission = .none
    static var previews: some View {
        NavigationStack {
            List {
                DeviceDemosSection(mission: mission)
            }
            .navigationDestination(for: DeviceDemo.self) { deviceDemo in
                deviceDemo.view(mission: mission)
            }
        }
        .frame(maxWidth: 300, maxHeight: 300)
    }
}
