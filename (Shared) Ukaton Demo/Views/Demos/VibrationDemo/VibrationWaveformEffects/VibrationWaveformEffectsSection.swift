import SwiftUI
import UkatonKit

struct VibrationWaveformEffectsSection: View {
    var vibratable: UKVibratable
    @State private var waveformEffectsArray: [[UKVibrationWaveformEffect]] = []

    var body: some View {
        Section {
            NavigationLink("Explore Effects...") {
                AllVibrationWaveformEffectsView(vibratable: vibratable)
            }

            Button(action: {
                waveformEffectsArray.append([])
            }) {
                Label("Add Sequence", systemImage: "plus")
            }

            ForEach(0 ..< waveformEffectsArray.count, id: \.self) { waveformEffectsIndex in
                HStack {
                    Text("Sequence \(waveformEffectsIndex + 1)")
                        .bold()
                    Spacer()
                    Button(role: .destructive, action: {
                        waveformEffectsArray.remove(at: waveformEffectsIndex)
                    }) {
                        Text("remove")
                    }
                }
                VibrationWaveformEffectsView(vibratable: vibratable, waveformEffects: $waveformEffectsArray[waveformEffectsIndex])
            }

        } header: {
            Text("Waveform Effects")
                .font(.headline)
        }
    }
}

#Preview {
    NavigationStack {
        List {
            VibrationWaveformEffectsSection(vibratable: UKMission.none)
        }
    }
    #if os(macOS)
    .frame(maxWidth: 300, maxHeight: 300)
    #endif
}
