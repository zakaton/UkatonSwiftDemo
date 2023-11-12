import SwiftUI
import UkatonKit

struct PressureDemo: View {
    @ObservedObject var mission: UKMission
    @State private var sensorDataConfigurations: UKSensorDataConfigurations = .init()

    var body: some View {
        VStack {
            Image("leftInsole")
                .resizable()
                .scaledToFit()
                .scaleEffect(x: mission.deviceType == .leftInsole ? 1.0 : -1.0)
                .overlay {
                    GeometryReader { geometry in
                        ForEach(mission.sensorData.pressure.pressureValues) { pressureValue in
                            Rectangle()
                                .fill(.red)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                                .opacity(pressureValue.normalizedValue)
                                .frame(width: geometry.size.width * 0.18, height: geometry.size.height * 0.06)
                                .position(x: geometry.size.width * pressureValue.position.x, y: geometry.size.height * pressureValue.position.y)
                        }
                    }
                }
            PressureModePicker(mission: mission, sensorDataConfigurations: $sensorDataConfigurations)
        }
    }
}

#Preview {
    PressureDemo(mission: .none)
        .frame(maxWidth: 360, maxHeight: 300)
}
