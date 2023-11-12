import SwiftUI
import UkatonKit

struct VibrationDemo: View {
    @ObservedObject var mission: UKMission

    var body: some View {
        List {
            VibrationWaveformsSection(mission: mission)
            VibrationSequenceSection(mission: mission)
        }
        .navigationTitle("Vibration")
    }
}

#Preview {
    NavigationStack {
        VibrationDemo(mission: .none)
    }
    .frame(maxWidth: 360, maxHeight: 500)
}
