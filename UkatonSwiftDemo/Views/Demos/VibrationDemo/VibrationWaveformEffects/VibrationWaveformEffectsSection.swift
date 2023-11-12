import SwiftUI
import UkatonKit

struct VibrationWaveformEffectsSection: View {
    @ObservedObject var mission: UKMission
    @State private var waveformEffectsArray: [[UKVibrationWaveformEffect]] = []

    var body: some View {
        Section {
            NavigationLink("Explore Effects...") {
                AllVibrationWaveformEffectsView(mission: mission)
            }

            Button(action: {
                waveformEffectsArray.append([])
            }) {
                Label("Add Sequence", systemImage: "plus")
            }

            ForEach(0 ..< waveformEffectsArray.count, id: \.self) { waveformEffectsIndex in
                HStack {
                    Text("Sequence \(waveformEffectsIndex + 1)")
                    Spacer()
                    Button(role: .destructive, action: {
                        waveformEffectsArray.remove(at: waveformEffectsIndex)
                    }) {
                        Text("remove")
                    }
                }
                VibrationWaveformEffectsView(mission: mission, waveformEffects: $waveformEffectsArray[waveformEffectsIndex])
            }
            .onDelete(perform: { indexSet in
                waveformEffectsArray.remove(atOffsets: indexSet)
            })

        } header: {
            Text("Waveform Effects")
                .font(.headline)
        }
    }
}

#Preview {
    NavigationStack {
        List {
            VibrationWaveformEffectsSection(mission: .none)
        }
    }
    .frame(maxWidth: 300, maxHeight: 300)
}
