import Combine
import SceneKit
import Spatial
import SwiftUI
import UkatonKit

struct MotionView: View {
    var mission: UKMission

    private var recalibrateSubject: PassthroughSubject<Void, Never>? = nil

    // MARK: - SceneKit

    private var scene: SCNScene = .init()
    @State private var model: SCNScene?
    private var lightNode: SCNNode = .init()
    private var cameraNode: SCNNode = .init()

    // MARK: Listeners

    @State var offsetQuaternion: UKQuaternion = .init(angle: 0, axis: .init(0, 1, 0))
    func updateOffsetQuaternion() {
        let eulerAngles = mission.sensorData.motion.rotation.eulerAngles(order: .zxy)
        offsetQuaternion = UKQuaternion(angle: -eulerAngles.angles.y, axis: .init(0, 1, 0))
    }

    func onQuaternion(_ quaternion: UKQuaternion) {
        guard let model else { return }
        model.rootNode.orientation = .init((offsetQuaternion * quaternion).vector)
    }

    func onRotationRate(_ rotationRate: Rotation3D) {
        guard let model else { return }
        var eulerAngles = rotationRate.eulerAngles(order: .xyz)
        eulerAngles.angles *= 2.0
        model.rootNode.eulerAngles = .init(eulerAngles.angles)
    }

    func onLinearAcceleration(_ linearAcceleration: Vector3D) {
        guard let model else { return }
        model.rootNode.simdPosition.interpolate(to: .init(linearAcceleration * 0.05), with: 0.4)
    }

    func onAcceleration(_ acceleration: Vector3D) {
        guard let model else { return }
        model.rootNode.simdPosition.interpolate(to: .init(acceleration * 0.05), with: 0.4)
    }

    // MARK: - Setup

    func setupScene() {
        // MARK: - Model

        let modelName = mission.deviceType.isInsole ? "leftShoe" : "monkey"
        model = .init(named: "\(modelName).usdz")!
        if mission.deviceType == .rightInsole {
            model!.rootNode.scale.x = -1
        }
        scene.rootNode.addChildNode(model!.rootNode)

        // MARK: - Lights,

        lightNode.light = .init()
        lightNode.light!.type = .ambient
        scene.rootNode.addChildNode(lightNode)

        // MARK: - Camera...

        cameraNode.camera = SCNCamera()
        cameraNode.position = .init(x: 0, y: 0, z: 2)
        cameraNode.eulerAngles = .init(x: 0, y: 0, z: 0)
    }

    init(mission: UKMission, recalibrateSubject: PassthroughSubject<Void, Never>? = nil) {
        self.mission = mission
        self.recalibrateSubject = recalibrateSubject
    }

    var body: some View {
        SceneView(scene: scene, pointOfView: cameraNode, options: [.allowsCameraControl])
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .onReceive(mission.sensorData.motion.quaternionSubject, perform: { onQuaternion($0.value) })
            .onReceive(mission.sensorData.motion.rotationRateSubject, perform: { onRotationRate($0.value) })
            .onReceive(mission.sensorData.motion.accelerationSubject, perform: { onAcceleration($0.value) })
            .onReceive(mission.sensorData.motion.linearAccelerationSubject, perform: { onLinearAcceleration($0.value) })
            .onAppear {
                setupScene()
            }
            .modify {
                if let recalibrateSubject {
                    $0.onReceive(recalibrateSubject, perform: { _ in
                        updateOffsetQuaternion()
                    })
                }
            }
    }
}

#Preview {
    NavigationStack {
        MotionView(mission: .none)
    }
    .frame(maxWidth: 360, maxHeight: 500)
}
