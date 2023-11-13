import SwiftUI
import UkatonKit

struct VibrationDemo: View {
    var mission: UKMission

    var body: some View {
        List {
            VibrationWaveformEffectsSection(mission: mission)
            VibrationWaveformsSection(mission: mission)
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
