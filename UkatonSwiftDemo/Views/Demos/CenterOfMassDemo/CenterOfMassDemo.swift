import SwiftUI
import UkatonKit

struct CenterOfMassDemo: View {
    let centerOfMassProvider: UKCenterOfMassProvider

    @State private var sensorDataConfigurations: UKSensorDataConfigurations = .init()

    @State var centerOfMass: UKCenterOfMass = .init()

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ZStack {
                    RoundedRectangle(cornerRadius: 15.0)
                        .fill(.blue)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            GeometryReader { geometry in
                                Circle()
                                    .fill(.red)
                                    .frame(width: min(geometry.size.width, geometry.size.height) * 0.15)
                                    .position(
                                        x: geometry.size.width * centerOfMass.x,
                                        y: geometry.size.height * (1 - centerOfMass.y)
                                    )
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .frame(width: geometry.size.width - 10, height: geometry.size.height - 10)
                }
            }
            .onReceive(centerOfMassProvider.centerOfMassSubject.dropFirst(), perform: {
                centerOfMass = $0.value
            })
            .padding(10)

            PressureModePicker(sensorDataConfigurable: centerOfMassProvider, sensorDataConfigurations: $sensorDataConfigurations)
        }
        .navigationTitle("Center of Mass")
        .onReceive(centerOfMassProvider.sensorDataConfigurationsSubject, perform: {
            sensorDataConfigurations = $0
        })
        .toolbar {
            let button = Button {
                centerOfMassProvider.recalibrateCenterOfMass()
            } label: {
                Label("recalibrate pressure", systemImage: "arrow.counterclockwise")
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
        .onDisappear {
            try? centerOfMassProvider.clearSensorDataConfigurations()
        }
    }
}

#Preview {
    NavigationStack {
        CenterOfMassDemo(centerOfMassProvider: UKMissionPair.shared)
    }
    #if os(macOS)
    .frame(maxWidth: 300, maxHeight: 300)
    #endif
}
