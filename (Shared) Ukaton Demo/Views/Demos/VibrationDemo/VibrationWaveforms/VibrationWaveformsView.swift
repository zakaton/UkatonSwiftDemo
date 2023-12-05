import SwiftUI
import UkatonKit

struct VibrationWaveformsView: View {
    var vibratable: UKVibratable
    @Binding var waveforms: [UKVibrationWaveform]

    @ViewBuilder
    func centerView(_ view: some View) -> some View {
        if isWatch {
            HStack {
                Spacer()
                view
                Spacer()
            }
        }
        else {
            view
        }
    }

    var body: some View {
        let layout = isWatch ? AnyLayout(VStackLayout(alignment: .leading)) : AnyLayout(HStackLayout())

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
            layout {
                centerView(Text("intensity"))
                #if os(tvOS)
                Picker(selection: $waveforms[index].intensity) {
                    ForEach(Array(stride(from: 0, through: 1, by: 0.1)), id: \.self) { intensity in
                        Text("\(Int(intensity * 100))%")
                            .tag(UKVibrationWaveformIntensity(intensity))
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.menu)
                #else
                Slider(value: $waveforms[index].intensity)
                #endif
            }
            layout {
                #if os(tvOS)
                centerView(Text("delay"))
                Picker(selection: $waveforms[index].delay) {
                    ForEach(Array(stride(from: 0, through: UKVibrationWaveformDelay.max, by: 200)), id: \.self) { delay in
                        Text(String(format: "%.1fs", delay / 1000))
                            .tag(UKVibrationWaveformDelay(delay))
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.menu)
                #else
                centerView(Text(String(format: "delay %.1fs", waveforms[index].delay / 1000)))
                Slider(value: $waveforms[index].delay, in: 0 ... UKVibrationWaveformDelay.max, step: isWatch ? 200 : 100)
                #endif
            }
        }

        Button(action: {
            try? vibratable.vibrate(waveforms: waveforms)
        }) {
            Label("trigger sequence", systemImage: "waveform.path")
        }
        .disabled(waveforms.isEmpty)
    }
}

#Preview {
    @State var waveforms: [UKVibrationWaveform] = [.init(intensity: 0.5, delay: 1000)]
    return VibrationWaveformsView(vibratable: UKMission.none, waveforms: $waveforms)
    #if os(macOS)
        .frame(maxWidth: 300, maxHeight: 100)
    #endif
}
