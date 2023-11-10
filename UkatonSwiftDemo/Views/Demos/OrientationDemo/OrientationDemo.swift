import Combine
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

struct OrientationDemo: View, Equatable {
    static func == (lhs: OrientationDemo, rhs: OrientationDemo) -> Bool {
        lhs.mission == rhs.mission && lhs.mission.deviceType == rhs.mission.deviceType
    }

    @ObservedObject var mission: UKMission
    @State private var newSensorDataConfigurations: UKSensorDataConfigurations = .init()

    // MARK: - SceneKit

    private var scene: SCNScene = .init()
    @State private var model: SCNScene!
    private var lightNode: SCNNode = .init()
    private var cameraNode: SCNNode = .init()

    // MARK: Listeners

    private var cancellables = Set<AnyCancellable>()

    func onQuaternion(_ quaternion: Quaternion) {
        print(quaternion.string)
        model.rootNode.orientation = .init(quaternion.vector)
    }

    func onRotationRate(_ rotationRate: Rotation3D) {
        // TODO: - FILL
        print(rotationRate.string)
    }

    func onLinearAcceleration(_ linearAcceleration: Vector3D) {
        // TODO: - FILL
        print(linearAcceleration.string)
    }

    func onAcceleration(_ acceleration: Vector3D) {
        // TODO: - FILL
        print(acceleration.string)
    }

    // MARK: - Setup

    func setupScene() {
        // MARK: - Model

        let modelName = mission.deviceType.isInsole ? "leftShoe" : "monkey"
        model = .init(named: "\(modelName).usdz")!
        if mission.deviceType == .rightInsole {
            model.rootNode.scale.x = -0.5
        }
        onQuaternion(mission.sensorData.motion.quaternion)
        scene.rootNode.addChildNode(model.rootNode)

        // MARK: - Lights,

        lightNode.light = .init()
        lightNode.light!.type = .ambient
        scene.rootNode.addChildNode(lightNode)

        // MARK: - Camera...

        cameraNode.camera = SCNCamera()
        cameraNode.position = .init(x: 0, y: 0, z: 2)
        cameraNode.eulerAngles = .init(x: 0, y: 0, z: 0)
    }

    init(mission: UKMission) {
        self.mission = mission
    }

    var body: some View {
        VStack {
            SceneView(scene: scene, pointOfView: cameraNode, options: [.allowsCameraControl])
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onReceive(mission.sensorData.motion.quaternionSubject, perform: { onQuaternion($0.quaternion) })
                .onReceive(mission.sensorData.motion.rotationRateSubject, perform: { onRotationRate($0.rotationRate) })
                .onReceive(mission.sensorData.motion.accelerationSubject, perform: { onAcceleration($0.acceleration) })
                .onReceive(mission.sensorData.motion.linearAccelerationSubject, perform: { onLinearAcceleration($0.linearAcceleration) })
            RotationModePicker(mission: mission, newSensorDataConfigurations: $newSensorDataConfigurations)
            TranslationModePicker(mission: mission, newSensorDataConfigurations: $newSensorDataConfigurations)
        }
        .onAppear {
            setupScene()
        }
        .onDisappear {
            try? mission.clearSensorDataConfigurations()
        }
        .navigationTitle("Orientation")
    }
}

#Preview {
    OrientationDemo(mission: .none)
        .frame(maxWidth: 360, maxHeight: 300)
}
