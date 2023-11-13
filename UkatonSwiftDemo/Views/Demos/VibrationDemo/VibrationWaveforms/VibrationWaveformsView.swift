import SwiftUI
import UkatonKit

struct VibrationWaveformsView: View {
    var mission: UKMission
    @Binding var waveforms: [UKVibrationWaveform]

    var body: some View {
        Button(action: {
            waveforms.append((waveforms.isEmpty ? .init(intensity: 0.5, delay: 200) : waveforms.last)!)
        }) {
            Label("add waveform", systemImage: "plus")
        }
        .disabled(waveforms.count >= UKVibrationType.waveform.maxSequenceLength)

        ForEach(waveforms.indices, id: \.self) { index in
            HStack {
                Text("waveform \(index + 1)")
                    .bold()
                Spacer()
                Button(role: .destructive, action: {
                    waveforms.remove(at: index)
                }) {
                    Text("remove")
                }
            }
            HStack {
                Text("intensity")
                Slider(value: $waveforms[index].intensity)
            }
            HStack {
                Text(String(format: "delay %.1fs", waveforms[index].delay / 1000))
                Slider(value: $waveforms[index].delay, in: 0 ... UKVibrationWaveformDelay.max, step: 100)
            }
        }

        Button(action: {
            try? mission.vibrate(waveforms: waveforms)
        }) {
            Text("trigger waveforms")
        }
        .disabled(waveforms.isEmpty)
    }
}

#Preview {
    VibrationWaveformsView(mission: .none, waveforms: .constant(.init()))
}
