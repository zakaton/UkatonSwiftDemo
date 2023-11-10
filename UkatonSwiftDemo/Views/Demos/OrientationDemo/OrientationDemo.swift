import Combine
import ModelIO
import SceneKit
import Spatial
import SwiftUI
import UkatonKit
import UkatonMacros

// TODO: - quaternion
// TODO: - rotationRate
// TODO: - linearAcceleration
// TODO: - acceleration
// TODO: - refactor

struct OrientationDemo: View {
    @ObservedObject var mission: UKMission

    // MARK: - SceneKit

    private var scene: SCNScene = .init()
    private var model: SCNScene
    private var lightNode: SCNNode = .init()
    private var cameraNode: SCNNode = .init()

    // MARK: - SensorDataConfig

    @State private var newSensorDataConfigurations: UKSensorDataConfigurations = .init()

    var isQuaternionEnabled: Bool {
        mission.sensorDataConfigurations.motion[.quaternion]! > 0
    }

    var isRotationRateEnabled: Bool {
        mission.sensorDataConfigurations.motion[.rotationRate]! > 0
    }

    var isLinearAccelerationEnabled: Bool {
        mission.sensorDataConfigurations.motion[.linearAcceleration]! > 0
    }

    var isAccelerationEnabled: Bool {
        mission.sensorDataConfigurations.motion[.acceleration]! > 0
    }

    // MARK: - controls

    @EnumName
    enum RotationMode: CaseIterable, Identifiable {
        var id: String { name }

        case none
        case quaternion
        case rotationRate
    }

    @State private var selectedRotationMode: RotationMode = .none

    @EnumName
    enum TranslationMode: CaseIterable, Identifiable {
        var id: String { name }

        case none
        case linearAcceleration
        case acceleration
    }

    @State private var selectedTranslationMode: TranslationMode = .none

    // MARK: Listeners

    private var cancellables = Set<AnyCancellable>()

    func onQuaternion(_ quaternion: Quaternion) {
        print(quaternion)
        model.rootNode.orientation = .init(quaternion.vector)
    }

    func onRotationRate(_ rotationRate: Rotation3D) {
        // TODO: - FILL
    }

    func onLinearAcceleration(_ linearAcceleration: Vector3D) {
        // TODO: - FILL
    }

    func onAcceleration(_ acceleration: Vector3D) {
        // TODO: - FILL
    }

    func onSensorDataConfigurationsUpdate(_ sensorDataConfigurations: UKSensorDataConfigurations) {
        // TODO: - FILL
    }

    // MARK: - Setup

    init(mission: UKMission) {
        self.mission = mission

        // MARK: - Model

        let modelName = mission.deviceType.isInsole ? "leftShoe" : "monkey"
        model = .init(named: "\(modelName).usdz")!
        if mission.deviceType == .rightInsole {
            model.rootNode.scale.x = -0.5
        }
        scene.rootNode.addChildNode(model.rootNode)

        // MARK: - Lights,

        lightNode.light = .init()
        lightNode.light!.type = .ambient
        scene.rootNode.addChildNode(lightNode)

        // MARK: - Camera...

        cameraNode.camera = SCNCamera()
        cameraNode.position = .init(x: 0, y: 0, z: 2)
        cameraNode.eulerAngles = .init(x: 0, y: 0, z: 0)

        // MARK: - Action!

        mission.sensorData.motion.quaternionSubject.sink {
            [self] in onQuaternion($0.quaternion)
        }.store(in: &cancellables)

        mission.sensorData.motion.rotationRateSubject.sink {
            [self] in onRotationRate($0.rotationRate)
        }.store(in: &cancellables)

        mission.sensorData.motion.accelerationSubject.sink {
            [self] in onAcceleration($0.acceleration)
        }.store(in: &cancellables)

        mission.sensorData.motion.linearAccelerationSubject.sink {
            [self] in onLinearAcceleration($0.linearAcceleration)
        }.store(in: &cancellables)

        mission.$sensorDataConfigurations.sink { [self] sensorDataConfigurations in
            self.onSensorDataConfigurationsUpdate(sensorDataConfigurations)
        }.store(in: &cancellables)
    }

    var body: some View {
        ZStack {
            SceneView(scene: scene, pointOfView: cameraNode)
            HStack {
                Spacer()
                VStack {
                    let rotationBinding = Binding<RotationMode>(
                        get: {
                            if isQuaternionEnabled {
                                return .quaternion
                            }
                            else if isRotationRateEnabled {
                                return .rotationRate
                            }
                            else {
                                return .none
                            }
                        },
                        set: {
                            newSensorDataConfigurations.motion[.quaternion] = 0
                            newSensorDataConfigurations.motion[.rotationRate] = 0

                            switch $0 {
                            case .none:
                                break
                            case .quaternion:
                                newSensorDataConfigurations.motion[.quaternion] = 20
                            case .rotationRate:
                                newSensorDataConfigurations.motion[.rotationRate] = 20
                            }

                            try? mission.setSensorDataConfigurations(newSensorDataConfigurations)
                        })

                    Picker(selection: rotationBinding, label: EmptyView()) {
                        ForEach(RotationMode.allCases) { rotationMode in
                            Text(rotationMode.name)
                                .tag(rotationMode)
                        }
                    }
                    .pickerStyle(.segmented)

                    Spacer()

                    let translationBinding = Binding<TranslationMode>(
                        get: {
                            if isAccelerationEnabled {
                                return .acceleration
                            }
                            else if isLinearAccelerationEnabled {
                                return .linearAcceleration
                            }
                            else {
                                return .none
                            }
                        },
                        set: {
                            newSensorDataConfigurations.motion[.acceleration] = 0
                            newSensorDataConfigurations.motion[.linearAcceleration] = 0

                            switch $0 {
                            case .none:
                                break
                            case .acceleration:
                                newSensorDataConfigurations.motion[.acceleration] = 20
                            case .linearAcceleration:
                                newSensorDataConfigurations.motion[.linearAcceleration] = 20
                            }

                            try? mission.setSensorDataConfigurations(newSensorDataConfigurations)
                        })

                    Picker(selection: translationBinding, label: EmptyView()) {
                        ForEach(TranslationMode.allCases) { translationMode in
                            Text(translationMode.name)
                                .tag(translationMode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
        .onDisappear {
            try? mission.clearSensorDataConfigurations()
        }
    }
}

#Preview {
    OrientationDemo(mission: .none)
        .frame(maxWidth: 360, maxHeight: 300)
}
