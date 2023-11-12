import Combine
import SceneKit
import Spatial
import SwiftUI
import UkatonKit
import UkatonMacros

func interpolate(start: simd_float3, end: simd_float3, factor: Float) -> simd_float3 {
    let clampedFactor = max(0.0, min(1.0, factor))
    let interpolatedVector = (1.0 - clampedFactor) * start + clampedFactor * end
    return interpolatedVector
}

struct MotionDemo: View, Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.mission == rhs.mission && lhs.mission.deviceType == rhs.mission.deviceType
    }

    @ObservedObject var mission: UKMission
    @State private var sensorDataConfigurations: UKSensorDataConfigurations = .init()

    // MARK: - SceneKit

    private var scene: SCNScene = .init()
    @State private var model: SCNScene!
    private var lightNode: SCNNode = .init()
    private var cameraNode: SCNNode = .init()

    // MARK: Listeners

    @State var offsetYaw: Double = 0
    @State var offsetQuaternion: Quaternion = .init(angle: 0, axis: .init(0, 1, 0))
    func onQuaternion(_ quaternion: Quaternion) {
        model.rootNode.orientation = .init((offsetQuaternion * quaternion).vector)
    }

    func onRotationRate(_ rotationRate: Rotation3D) {
        var eulerAngles = rotationRate.eulerAngles(order: .xyz)
        eulerAngles.angles *= 2.0
        model.rootNode.eulerAngles = .init(eulerAngles.angles)
    }

    func onLinearAcceleration(_ linearAcceleration: Vector3D) {
        model.rootNode.simdPosition = interpolate(start: model.rootNode.simdPosition, end: .init(linearAcceleration * 0.05), factor: 0.4)
    }

    func onAcceleration(_ acceleration: Vector3D) {
        model.rootNode.simdPosition = interpolate(start: model.rootNode.simdPosition, end: .init(acceleration * 0.05), factor: 0.4)
    }

    // MARK: - Setup

    func setupScene() {
        // MARK: - Model

        let modelName = mission.deviceType.isInsole ? "leftShoe" : "monkey"
        model = .init(named: "\(modelName).usdz")!
        if mission.deviceType == .rightInsole {
            model.rootNode.scale.x = -1
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

            RotationModePicker(mission: mission, sensorDataConfigurations: $sensorDataConfigurations)
            TranslationModePicker(mission: mission, sensorDataConfigurations: $sensorDataConfigurations)
        }
        .onReceive(mission.sensorDataConfigurationsSubject, perform: {
            sensorDataConfigurations = $0
        })
        .onAppear {
            setupScene()
        }
        .onDisappear {
            try? mission.clearSensorDataConfigurations()
        }
        .toolbar {
            Button {
                let eulerAngles = mission.sensorData.motion.rotation.eulerAngles(order: .zxy)
                offsetQuaternion = Quaternion(angle: -eulerAngles.angles.y, axis: .init(0, 1, 0))
            } label: {
                Label("reset orientation", systemImage: "arrow.counterclockwise")
            }
        }
        .navigationTitle("Motion")
    }
}

#Preview {
    NavigationStack { MotionDemo(mission: .none) }
        .frame(maxWidth: 360, maxHeight: 500)
}
