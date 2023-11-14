import Combine
import SwiftUI
import UkatonKit

struct MissionPairMotionDemo: View {
    let missionPair: UKMissionPair
    
    private let recalibrateSubject: PassthroughSubject<Void, Never> = .init()

    var body: some View {
        HStack {
            MotionDemo(mission: missionPair[.left] ?? .none, showToolbar: false, recalibrateSubject: recalibrateSubject)
            MotionDemo(mission: missionPair[.right] ?? .none, showToolbar: false, recalibrateSubject: recalibrateSubject)
        }
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
    MissionPairMotionDemo(missionPair: .shared)
        .frame(maxWidth: 500, maxHeight: 300)
}
