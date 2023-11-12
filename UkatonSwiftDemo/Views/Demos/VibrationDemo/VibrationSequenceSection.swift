import SwiftUI
import UkatonKit

struct VibrationSequenceSection: View {
    @ObservedObject var mission: UKMission
    @State private var sequence: [UKVibrationSequenceSegment] = []

    func vibrate() {
        try? mission.vibrate(sequence: sequence)
    }

    var body: some View {
        Section {} header: {
            Text("Sequence")
                .font(.headline)
        }
    }
}

#Preview {
    List {
        VibrationSequenceSection(mission: .none)
    }
    .frame(maxWidth: 300)
}
