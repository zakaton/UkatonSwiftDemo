import SwiftUI
import UkatonKit

struct PressureDemo: View {
    var mission: UKMission
    @State private var sensorDataConfigurations: UKSensorDataConfigurations = .init()
    @State private var pressureValues: UKPressureValues = .init()

    var body: some View {
        VStack {
            Image("leftInsole")
                .resizable()
                .scaledToFit()
                .scaleEffect(x: mission.deviceType == .leftInsole ? 1.0 : -1.0)
                .overlay {
                    GeometryReader { geometry in
                        ForEach(pressureValues) { pressureValue in
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
        .navigationTitle("Pressure")
        .onReceive(mission.sensorDataConfigurationsSubject, perform: {
            sensorDataConfigurations = $0
        })
        .onReceive(mission.sensorData.pressure.pressureValuesSubject, perform: { pressureValues = $0.value })
        .onDisappear {
            try? mission.clearSensorDataConfigurations()
        }
    }
}

#Preview {
    PressureDemo(mission: .none)
        .frame(maxWidth: 360, maxHeight: 300)
}
