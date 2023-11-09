import SwiftUI
import UkatonKit

struct PressureDemo: View {
    @ObservedObject var mission: UKMission

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    PressureDemo(mission: .none)
        .frame(maxWidth: 360, maxHeight: 300)
}
