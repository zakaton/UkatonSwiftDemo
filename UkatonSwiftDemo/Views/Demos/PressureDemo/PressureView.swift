import SwiftUI
import UkatonKit

struct PressureView: View {
    var mission: UKMission
    @State private var pressureValues: UKPressureValues? = nil

    var body: some View {
        Image("leftInsole")
            .resizable()
            .scaledToFit()
            .scaleEffect(x: mission.deviceType == .leftInsole ? 1.0 : -1.0)
            .overlay {
                if let pressureValues {
                    GeometryReader { geometry in
                        ForEach(pressureValues) { pressureValue in
                            ZStack {
                                Rectangle()
                                    .fill(.gray)
                                Rectangle()
                                    .fill(.red)
                                    .opacity(pressureValue.normalizedValue)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .frame(width: geometry.size.width * 0.18, height: geometry.size.height * 0.06)
                            .position(x: geometry.size.width * pressureValue.position.x, y: geometry.size.height * pressureValue.position.y)
                        }
                    }
                }
            }
            .onReceive(mission.sensorData.pressure.pressureValuesSubject.dropFirst(), perform: {
                pressureValues = $0.value
            })
    }
}

#Preview {
    PressureView(mission: .none)
        .frame(maxWidth: 360, maxHeight: 300)
}
