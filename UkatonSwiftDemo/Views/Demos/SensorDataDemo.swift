import SwiftUI
import UkatonKit

struct SensorDataDemo: View {
    @ObservedObject private var mission: UKMission

    init(mission: UKMission) {
        self.mission = mission
    }

    var body: some View {
        Text("Sensor Data")
            .navigationTitle("Sensor Data")
    }
}

#Preview {
    SensorDataDemo(mission: .none)
}
