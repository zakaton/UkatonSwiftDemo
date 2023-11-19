import SwiftUI
import UkatonKit

struct AllVibrationWaveformEffectsView: View {
    var vibratable: UKVibratable

    var body: some View {
        List {
            ForEach(UKVibrationWaveformEffect.allCases.filter { $0 != .none }) { waveformEffect in
                Button(action: {
                    try? vibratable.vibrate(waveformEffect: waveformEffect)
                }, label: {
                    Text(waveformEffect.name)
                })
            }
        }
        .navigationTitle("All Waveform Effects")
    }
}

#Preview {
    NavigationStack {
        AllVibrationWaveformEffectsView(vibratable: UKMission.none)
    }
#if os(macOS)
    .frame(maxWidth: 400)
#endif
}
