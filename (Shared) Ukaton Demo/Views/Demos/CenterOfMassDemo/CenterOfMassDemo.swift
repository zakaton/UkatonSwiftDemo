import simd
import SwiftUI
import UkatonKit

/**
 TODO:
    -start/stop timer
    -reset if inside target for 2 seconds
 */

extension CGRect {
    func contains(_ point: UKCenterOfMass) -> Bool {
        let cgPoint: CGPoint = .init(
            x: point.x + (width/2),
            y: point.y + (height/2)
        )
        return contains(cgPoint)
    }
}

struct CenterOfMassDemo: View {
    let centerOfMassProvider: UKCenterOfMassProvider

    @State private var sensorDataConfigurations: UKSensorDataConfigurations = .init()

    @State private var isInsideTarget = false {
        didSet {
            if isInsideTarget != oldValue {
                if isInsideTarget {
                    firstTimeInsideTarget = .now
                }
            }
        }
    }

    @State private var centerOfMass: UKCenterOfMass = .init() {
        didSet {
            if isPlayingGame {
                let newIsInsideTarget = target.contains(centerOfMass)
                if newIsInsideTarget != isInsideTarget {
                    isInsideTarget = newIsInsideTarget
                }
                else {
                    if isInsideTarget && timeInsideTarget > 2 {
                        resetTarget()
                    }
                }
            }
        }
    }

    @State private var firstTimeInsideTarget: Date = .now
    private var timeInsideTarget: TimeInterval { -firstTimeInsideTarget.timeIntervalSinceNow }

    @State private var isPlayingGame = false
    func toggleGame() {
        isPlayingGame.toggle()
        if isPlayingGame {
            resetTarget()
        }
    }

    @State private var target: CGRect = .init()
    func resetTarget() {
        target.size.width = .random(in: 0.1 ... 0.3)
        target.size.height = .random(in: 0.1 ... 0.3)

        target.origin.x = .random(in: target.size.width/2 ... 1 - target.size.width/2)
        target.origin.y = .random(in: target.size.height/2 ... 1 - target.size.height/2)
    }

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
                                if isPlayingGame {
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .fill(isInsideTarget ? .green : .yellow)
                                        .frame(
                                            width: geometry.size.width * target.size.width,
                                            height: geometry.size.height * target.size.height
                                        )
                                        .position(
                                            x: geometry.size.width * target.origin.x,
                                            y: geometry.size.height * (1 - target.origin.y)
                                        )
                                }
                                Circle()
                                    .fill(.red)
                                    .frame(width: min(geometry.size.width, geometry.size.height) * 0.1)
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
            let recalibrateButton = Button {
                centerOfMassProvider.recalibrateCenterOfMass()
            } label: {
                Label("recalibrate pressure", systemImage: "arrow.counterclockwise")
            }
            let toggleGameButton = Button {
                toggleGame()
            } label: {
                Label("toggle game", systemImage: isPlayingGame ? "stop.fill" : "play.fill")
            }
            #if os(watchOS)
            ToolbarItem(placement: .topBarTrailing) {
                recalibrateButton
                    .foregroundColor(.primary)
            }
            ToolbarItem(placement: .bottomBar) {
                toggleGameButton
                    .foregroundColor(.primary)
            }
            #else
            ToolbarItem {
                recalibrateButton
            }
            ToolbarItem {
                toggleGameButton
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
    .frame(maxWidth: 350, maxHeight: 300)
    #endif
}
