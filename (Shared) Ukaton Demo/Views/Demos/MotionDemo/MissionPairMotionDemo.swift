import Combine
import SwiftUI
import UkatonKit

struct MissionPairMotionDemo: View {
    let missionPair: UKMissionPair

    @State private var sensorDataConfigurations: UKSensorDataConfigurations = .init()

    private let recalibrateSubject: PassthroughSubject<Void, Never> = .init()

    var body: some View {
        VStack {
            HStack {
                MotionView(mission: missionPair[.left] ?? .none, recalibrateSubject: recalibrateSubject)
                MotionView(mission: missionPair[.right] ?? .none, recalibrateSubject: recalibrateSubject)
            }

            RotationModePicker(sensorDataConfigurable: missionPair, sensorDataConfigurations: $sensorDataConfigurations)
            TranslationModePicker(sensorDataConfigurable: missionPair, sensorDataConfigurations: $sensorDataConfigurations)
        }
        .onDisappear {
            try? missionPair.clearSensorDataConfigurations()
        }
        .navigationTitle("Motion")
        .toolbar {
            Button {
                recalibrateSubject.send(())
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .accessibilityLabel("reset orientation")
            }
        }
    }
}

#Preview {
    NavigationStack {
        MissionPairMotionDemo(missionPair: .shared)
    }
    #if os(macOS)
    .frame(maxWidth: 500, maxHeight: 300)
    #endif
}
