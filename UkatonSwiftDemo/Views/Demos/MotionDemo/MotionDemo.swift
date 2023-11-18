import Combine
import SwiftUI
import UkatonKit
import UkatonMacros

struct MotionDemo: View {
    var mission: UKMission
    @State private var sensorDataConfigurations: UKSensorDataConfigurations = .init()

    private let recalibrateSubject: PassthroughSubject<Void, Never> = .init()

    init(mission: UKMission) {
        self.mission = mission
    }

    var body: some View {
        VStack {
            MotionView(mission: mission, recalibrateSubject: recalibrateSubject)

            RotationModePicker(sensorDataConfigurable: mission, sensorDataConfigurations: $sensorDataConfigurations)
            TranslationModePicker(sensorDataConfigurable: mission, sensorDataConfigurations: $sensorDataConfigurations)
        }
        .navigationTitle("Motion")
        .onReceive(mission.sensorDataConfigurationsSubject, perform: {
            sensorDataConfigurations = $0
        })
        .onDisappear {
            try? mission.clearSensorDataConfigurations()
        }
        .toolbar {
            let button = Button {
                recalibrateSubject.send(())
            } label: {
                Label("reset orientation", systemImage: "arrow.counterclockwise")
            }
            #if os(watchOS)
            ToolbarItem(placement: .topBarTrailing) {
                button
                    .foregroundColor(.primary)
            }
            #else
            ToolbarItem {
                button
            }
            #endif
        }
    }
}

#Preview {
    NavigationStack {
        MotionDemo(mission: .none)
    }
    .frame(maxWidth: 360, maxHeight: 500)
}
