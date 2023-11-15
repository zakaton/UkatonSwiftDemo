import SwiftUI
import UkatonKit

struct VibrationWaveformEffectsView: View {
    var vibratable: UKVibratable
    @Binding var waveformEffects: [UKVibrationWaveformEffect]

    var body: some View {
        Button(action: {
            waveformEffects.append((waveformEffects.isEmpty ? .buzz100 : waveformEffects.last)!)
        }) {
            Label("add waveform effect", systemImage: "plus")
        }
        .disabled(waveformEffects.count >= UKVibrationType.waveformEffect.maxSequenceLength)

        ForEach(waveformEffects.indices, id: \.self) { index in
            Picker("", selection: $waveformEffects[index]) {
                ForEach(UKVibrationWaveformEffect.allCases) { waveformEffect in
                    Text(waveformEffect.name)
                        .tag(waveformEffect)
                }
            }
        }
        .onDelete(perform: { indexSet in
            waveformEffects.remove(atOffsets: indexSet)
        })

        Button(action: {
            try? vibratable.vibrate(waveformEffects: waveformEffects)
        }) {
            HStack {
                Label("trigger sequence", systemImage: "waveform.path")
            }
        }
        .disabled(waveformEffects.isEmpty)
    }
}

#Preview {
    VibrationWaveformEffectsView(vibratable: UKMission.none, waveformEffects: .constant(.init()))
}
