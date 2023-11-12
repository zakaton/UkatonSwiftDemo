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
            NavigationLink("Explore Waveforms") {
                AllVibrationWaveformsView(mission: mission)
            }

            ForEach(waveforms) { waveform in
                Text(waveform.name)
            }
            .onDelete(perform: { indexSet in
                waveforms.remove(atOffsets: indexSet)
            })

            Button(action: {
                waveforms.append((waveforms.isEmpty ? .buzz100 : waveforms.last)!)
            }) {
                Label("add waveform", systemImage: "plus")
            }

            Button(action: {
                vibrate(waveforms: waveforms)
            }) {
                Text("trigger waveforms")
            }
            .disabled(waveforms.isEmpty)
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
