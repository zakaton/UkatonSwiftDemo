import SwiftUI
import UkatonKit

struct PressureView: View {
    var mission: UKMission
    @State private var pressureValues: UKPressureValues = .init()

    var body: some View {
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
            .onReceive(mission.sensorData.pressure.pressureValuesSubject, perform: { pressureValues = $0.value })
    }
}

#Preview {
    PressureView(mission: .none)
        .frame(maxWidth: 360, maxHeight: 300)
}
