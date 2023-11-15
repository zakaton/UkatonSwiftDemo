import SwiftUI
import UkatonKit

struct MissionPairCenterOfMassDemo: View {
    let missionPair: UKMissionPair

    @State private var sensorDataConfigurations: UKSensorDataConfigurations = .init()
    @State var centerOfMass: UKCenterOfMass = .init()

    var body: some View {
        VStack {
            Spacer()
            GeometryReader { geometry in
                ZStack {
                    RoundedRectangle(cornerRadius: 15.0)
                        .fill(.blue)
                    Circle()
                        .fill(.red)
                        .frame(width: min(geometry.size.width, geometry.size.height) * 0.1)
                        .position(
                            x: geometry.size.width * centerOfMass.x,
                            y: geometry.size.height * (1 - centerOfMass.y)
                        )
                }
            }
            .onReceive(missionPair.centerOfMassSubject, perform: {
                centerOfMass = $0.value
            })
            .padding(.horizontal)

            PressureModePicker(sensorDataConfigurable: missionPair, sensorDataConfigurations: $sensorDataConfigurations)
        }
        .navigationTitle("Center of Mass")
        .onReceive(missionPair.sensorDataConfigurationsSubject, perform: {
            sensorDataConfigurations = $0
        })
        .toolbar {
            Button {
                missionPair.recalibratePressure()
            } label: {
                Label("recalibrate pressure", systemImage: "arrow.counterclockwise")
            }
        }
        .onDisappear {
            try? missionPair.clearSensorDataConfigurations()
        }
    }
}

#Preview {
    MissionPairCenterOfMassDemo(missionPair: .shared)
        .frame(maxWidth: 300, maxHeight: 300)
}
