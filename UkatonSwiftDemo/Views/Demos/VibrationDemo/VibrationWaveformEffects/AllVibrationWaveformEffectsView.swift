import SwiftUI
import UkatonKit

struct AllVibrationWaveformEffectsView: View {
    var mission: UKMission

    var body: some View {
        List {
            ForEach(UKVibrationWaveformEffect.allCases.filter { $0 != .none }) { waveformEffect in
                Button(action: {
                    try? mission.vibrate(waveformEffect: waveformEffect)
                }, label: {
                    Text(waveformEffect.name)
                })
            }
        }
        .navigationTitle("All Waveform Effects")
    }
}

#Preview {
    AllVibrationWaveformEffectsView(mission: .none)
        .frame(maxWidth: 400)
}
