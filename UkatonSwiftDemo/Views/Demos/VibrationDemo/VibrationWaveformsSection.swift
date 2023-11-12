import SwiftUI
import UkatonKit

//
// TODO: - add waveform
// TODO: - waveform dropdown and

struct VibrationWaveformsSection: View {
    @ObservedObject var mission: UKMission
    @State private var waveforms: [UKVibrationWaveform] = []

    func vibrate(waveforms: [UKVibrationWaveform]) {
        try? mission.vibrate(waveforms: waveforms)
    }

    var body: some View {
        Section {
            Button(action: {
                vibrate(waveforms: waveforms)
            }) {
                Text("trigger waveforms")
            }
            .disabled(waveforms.isEmpty)
            NavigationLink("All Waveforms") {
                AllVibrationWaveformsView(mission: mission)
            }
        } header: {
            Text("Waveforms")
                .font(.headline)
        }
    }
}

#Preview {
    NavigationStack {
        List {
            VibrationWaveformsSection(mission: .none)
        }
    }
    .frame(maxWidth: 300, maxHeight: 300)
}
