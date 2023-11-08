import SwiftUI
import UkatonKit

struct MotionCalibrationSection: View {
    @ObservedObject var mission: UKMission

    var body: some View {
        Section {
            ForEach(UKMotionCalibrationType.allCases) { calibrationType in
                Text("__\(calibrationType.name.capitalized)__: \(mission.motionCalibration[calibrationType]!.name)")
            }
            Text("__Is fully calibrated?__ \(String(mission.isFullyCalibrated))")
        } header: {
            Text("Motion Calibration")
                .font(.headline)
        }
    }
}

#Preview {
    List {
        MotionCalibrationSection(mission: .none)
    }
    .frame(maxWidth: 300)
}
