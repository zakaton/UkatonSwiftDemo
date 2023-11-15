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
        .navigationTitle("Motion")
        .toolbar {
            Button {
                recalibrateSubject.send(())
            } label: {
                Label("reset orientation", systemImage: "arrow.counterclockwise")
            }
        }
    }
}

#Preview {
    NavigationStack { MissionPairMotionDemo(missionPair: .shared) }
        .frame(maxWidth: 500, maxHeight: 300)
}
