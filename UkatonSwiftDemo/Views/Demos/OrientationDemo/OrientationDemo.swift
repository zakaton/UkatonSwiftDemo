import SwiftUI
import UkatonKit

// TODO: - load model based on deviceType
// TODO: - quaternion
// TODO: - rotationRate
// TODO: - linearAcceleration

struct OrientationDemo: View {
    @ObservedObject var mission: UKMission

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    OrientationDemo(mission: .none)
        .frame(maxWidth: 360, maxHeight: 300)
}
