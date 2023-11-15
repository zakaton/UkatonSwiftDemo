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
    AllVibrationWaveformEffectsView(vibratable: UKMission.none)
        .frame(maxWidth: 400)
}
