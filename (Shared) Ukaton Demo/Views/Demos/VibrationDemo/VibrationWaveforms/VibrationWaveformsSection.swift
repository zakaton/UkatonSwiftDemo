import SwiftUI
import UkatonKit

struct VibrationWaveformsSection: View {
    var vibratable: UKVibratable
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
                VibrationWaveformsView(vibratable: vibratable, waveforms: $waveformsArray[waveformsIndex])
            }
        } header: {
            Text("Waveforms")
                .font(.headline)
        }
    }
}

#Preview {
    List {
        VibrationWaveformsSection(vibratable: UKMission.none)
    }
    #if os(macOS)
    .frame(maxWidth: 300, maxHeight: 300)
    #endif
}
