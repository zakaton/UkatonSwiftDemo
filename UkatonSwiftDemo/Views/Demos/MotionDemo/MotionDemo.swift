import Combine
import SceneKit
import Spatial
import SwiftUI
import UkatonKit
import UkatonMacros

// TODO: - reset quaternion

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
    @State private var newSensorDataConfigurations: UKSensorDataConfigurations = .init()

    // MARK: - SceneKit

    private var scene: SCNScene = .init()
    @State private var model: SCNScene!
    private var lightNode: SCNNode = .init()
    private var cameraNode: SCNNode = .init()

    // MARK: Listeners

    @State var offsetYaw: Double = 0
    func onRotation(_ rotation: Rotation3D) {
        var eulerAngles = rotation.eulerAngles(order: .zxy)
        eulerAngles.angles.y -= offsetYaw
        model.rootNode.eulerAngles = .init(eulerAngles.angles)
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
                .onReceive(mission.sensorData.motion.rotationSubject, perform: { onRotation($0.rotation) })
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
        .toolbar {
            Button {
                print("reset")
                let eulerAngles = mission.sensorData.motion.rotation.eulerAngles(order: .zxy)
                offsetYaw = eulerAngles.angles.y
            } label: {
                Label("reset orientation", systemImage: "arrow.counterclockwise")
            }
        }
        .navigationTitle("Motion")
    }
}

#Preview {
    NavigationStack { MotionDemo(mission: .none) }
        .frame(maxWidth: 360, maxHeight: 300)
}