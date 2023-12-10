import SwiftUI
import UkatonKit

struct DiscoveredDeviceRowHeader: View {
    @Binding var discoveredDevice: UKDiscoveredBluetoothDevice
    @ObservedObject var mission: UKMission

    init(discoveredDevice: Binding<UKDiscoveredBluetoothDevice>) {
        self._discoveredDevice = discoveredDevice
        self.mission = discoveredDevice.wrappedValue.mission
    }

    var metadata: UKDeviceMetadata {
        discoveredDevice.metadata
    }

    var name: String {
        metadata.name
    }

    var deviceType: UKDeviceType {
        metadata.deviceType
    }

    var deviceTypeSystemImage: String {
        switch deviceType {
        case .motionModule:
            "rotate.3d"
        case .leftInsole, .rightInsole:
            "shoe"
        }
    }

    var body: some View {
        VStack(alignment: isWatch ? .center : .leading) {
            Text(name)
                .font(isWatch && mission.isConnected ? .body : .title2)
                .bold()

            HStack(spacing: 4) {
                Image(systemName: deviceTypeSystemImage)
                    .modify {
                        if deviceType == .leftInsole {
                            $0.scaleEffect(x: -1)
                        }
                    }
                Text(deviceType.name)
            }
        }
    }
}

#Preview {
    DiscoveredDeviceRowHeader(discoveredDevice: .constant(.none))
    #if os(macOS)
        .frame(maxWidth: 300)
    #endif
}
