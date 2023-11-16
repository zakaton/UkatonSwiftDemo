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
        VStack(alignment: .leading) {
            Text(name)
                .font(.title2)
                .bold()
            Label(deviceType.name, systemImage: deviceTypeSystemImage)
                .foregroundColor(.secondary)
                .labelStyle(LabelSpacing(spacing: 4))
        }
    }
}

#Preview {
    DiscoveredDeviceRowHeader(discoveredDevice: .constant(.none))
        .frame(maxWidth: 300)
}
