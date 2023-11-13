import SwiftUI
import UkatonKit

struct VibrationWaveformsSection: View {
    var mission: UKMission
    @State private var waveformsArray: [[UKVibrationWaveform]] = []

    var body: some View {
        Section {
            Button(action: {
                waveformsArray.append([])
            }) {
                Label("Add Sequence", systemImage: "plus")
            }

            ForEach(0 ..< waveformsArray.count, id: \.self) { waveformsIndex in
                HStack {
                    Text("Sequence \(waveformsIndex + 1)")
                    Spacer()
                    Button(role: .destructive, action: {
                        waveformsArray.remove(at: waveformsIndex)
                    }) {
                        Text("remove")
                    }
                }
                VibrationWaveformsView(mission: mission, waveforms: $waveformsArray[waveformsIndex])
            }
        } header: {
            Text("Waveforms")
                .font(.headline)
        }
    }
}

#Preview {
    List {
        VibrationWaveformsSection(mission: .none)
    }
    .frame(maxWidth: 300)
}
