import SwiftUI
import UkatonKit

struct VibrationWaveformEffectsView: View {
    var vibratable: UKVibratable
    @Binding var waveformEffects: [UKVibrationWaveformEffect]

    var isWatch: Bool {
        #if os(watchOS)
            true
        #else
            false
        #endif
    }

    @ViewBuilder
    func pickerLabel(index: Int) -> some View {
        if isWatch {
            EmptyView()
        } else {
            Text("\(index + 1)")
        }
    }

    var body: some View {
        Button(action: {
            waveformEffects.append((waveformEffects.isEmpty ? .buzz100 : waveformEffects.last)!)
        }) {
            Label("waveform effect", systemImage: "plus")
        }
        .disabled(waveformEffects.count >= UKVibrationType.waveformEffect.maxSequenceLength)

        ForEach(waveformEffects.indices, id: \.self) { index in
            HStack {
                if isWatch {
                    Text("\(index + 1)")
                }
                Picker(selection: $waveformEffects[index], label: pickerLabel(index: index)) {
                    ForEach(UKVibrationWaveformEffect.allCases) { waveformEffect in
                        Text(waveformEffect.name)
                            .tag(waveformEffect)
                            .foregroundColor(.primary)
                    }
                }
                #if os(tvOS)
                .pickerStyle(.menu)
                #endif
            }
        }
        .onDelete(perform: { indexSet in
            waveformEffects.remove(atOffsets: indexSet)
        })

        Button(action: {
            try? vibratable.vibrate(waveformEffects: waveformEffects)
        }) {
            Label("trigger sequence", systemImage: "waveform.path")
        }
        .disabled(waveformEffects.isEmpty)
    }
}

#Preview {
    @State var waveforms: [UKVibrationWaveformEffect] = [.alert750ms]
    return VibrationWaveformEffectsView(vibratable: UKMission.none, waveformEffects: $waveforms)
    #if os(macOS)
        .frame(maxWidth: 300, maxHeight: 300)
    #endif
}
