import SwiftUI
import UkatonKit

struct MotionCalibrationSection: View {
    var mission: UKMission

    @State private var motionCalibration: UKMotionCalibration = .init()
    @State private var isMotionFullyCalibrated: Bool = false

    var body: some View {
        Section {
            ForEach(motionCalibration.keys.sorted(by: {
                $0.rawValue < $1.rawValue
            })) { calibrationType in
                Text("__\(calibrationType.name.capitalized)__: \(motionCalibration[calibrationType]!.name)")
            }
            Text("__Is fully calibrated?__ \(String(isMotionFullyCalibrated))")
        } header: {
            Text("Motion Calibration")
                .font(.headline)
        }
        .onReceive(mission.motionCalibrationSubject, perform: { newMotionCalibration in
            motionCalibration = newMotionCalibration
        })
        .onReceive(mission.isMotionFullyCalibratedSubject, perform: { newIsMotionFullyCalibratedSubject in
            isMotionFullyCalibrated = newIsMotionFullyCalibratedSubject
        })
    }
}

#Preview {
    List {
        MotionCalibrationSection(mission: .none)
    }
    #if os(macOS)
    .frame(maxWidth: 300)
    #endif
}
