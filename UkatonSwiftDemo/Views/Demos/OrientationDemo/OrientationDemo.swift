import Combine
import ModelIO
import SceneKit
import SwiftUI
import UkatonKit

// TODO: - load model based on deviceType
// TODO: - quaternion
// TODO: - rotationRate
// TODO: - linearAcceleration

struct OrientationDemo: View {
    @ObservedObject var mission: UKMission
    @State private var newSensorDataConfigurations: UKSensorDataConfigurations = .init()

    var scene: SCNScene = .init()
    var model: SCNScene
    var lightNode: SCNNode = .init()

    var cameraNode: SCNNode? {
        scene.rootNode.childNode(withName: "camera", recursively: false)
    }

    var isQuaternionEnabled: Bool {
        mission.sensorDataConfigurations.motion[.quaternion]! > 0
    }

    init(mission: UKMission) {
        self.mission = mission

        model = .init(named: "leftShoe.usdz")!
        scene.rootNode.addChildNode(model.rootNode)

        lightNode.light = .init()
        lightNode.light!.type = .ambient
        scene.rootNode.addChildNode(lightNode)
    }

    var body: some View {
        ZStack {
            SceneView(scene: scene)
            HStack {
                Spacer()
                VStack {
                    Button(action: {
                        newSensorDataConfigurations.motion[.quaternion] = isQuaternionEnabled ? 0 : 20

                        try? mission.setSensorDataConfigurations(newSensorDataConfigurations)
                    }, label: {
                        if isQuaternionEnabled {
                            Text("disable")
                        }
                        else {
                            Text("enable")
                        }
                    })
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    OrientationDemo(mission: .none)
        .frame(maxWidth: 360, maxHeight: 300)
}
