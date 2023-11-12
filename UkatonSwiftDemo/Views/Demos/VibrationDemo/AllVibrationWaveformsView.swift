import SwiftUI
import UkatonKit

struct AllVibrationWaveformsView: View {
    @ObservedObject var mission: UKMission

    func vibrate(waveform: UKVibrationWaveform) {
        try? mission.vibrate(waveforms: [waveform])
    }

    var body: some View {
        List {
            ForEach(UKVibrationWaveform.allCases.filter { $0 != .none }) { waveform in
                Button(action: {
                    vibrate(waveform: waveform)
                }, label: {
                    Text(waveform.name)
                })
            }
        }
        .navigationTitle("All Waveform Vibrations")
    }
}

#Preview {
    AllVibrationWaveformsView(mission: .none)
        .frame(maxWidth: 400)
}
