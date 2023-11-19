import SwiftUI
import UkatonKit

struct VibrationDemo: View {
    var vibratable: UKVibratable

    var body: some View {
        List {
            VibrationWaveformEffectsSection(vibratable: vibratable)
            VibrationWaveformsSection(vibratable: vibratable)
        }
        .navigationTitle("Vibration")
    }
}

#Preview {
    NavigationStack {
        VibrationDemo(vibratable: UKMission.none)
    }
    #if os(macOS)
    .frame(maxWidth: 360, maxHeight: 500)
    #endif
}
