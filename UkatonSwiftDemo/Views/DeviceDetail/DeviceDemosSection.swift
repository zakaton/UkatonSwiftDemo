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
    case rssi

    var requiresPressure: Bool {
        switch self {
        case .pressure:
            true
        default:
            false
        }
    }

    var requiresBluetooth: Bool {
        switch self {
        case .rssi:
            true
        default:
            false
        }
    }

    func worksWith(mission: UKMission) -> Bool {
        guard !self.requiresPressure || mission.deviceType.isInsole else { return false }
        guard !self.requiresBluetooth || mission.connectionType == .bluetooth else { return false }
        return true
    }

    @ViewBuilder func view(mission: UKMission) -> some View {
        switch self {
        case .sensorData: SensorDataDemo(mission: mission)
        case .motion: MotionDemo(mission: mission)
        case .pressure: PressureDemo(mission: mission)
        case .vibration: VibrationDemo(vibratable: mission)
        case .rssi: RSSIDemo(mission: mission)
        }
    }
}

struct DeviceDemosSection: View {
    @ObservedObject var mission: UKMission

    var body: some View {
        Section {
            ForEach(DeviceDemo.allCases) { demo in
                if demo.worksWith(mission: self.mission) {
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
