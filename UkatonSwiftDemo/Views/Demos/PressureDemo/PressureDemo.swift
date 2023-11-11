import SwiftUI
import UkatonKit

struct PressureDemo: View {
    @ObservedObject var mission: UKMission

    var body: some View {
        Image("leftInsole")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

#Preview {
    PressureDemo(mission: .none)
        .frame(maxWidth: 360, maxHeight: 300)
}
