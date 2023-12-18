import AppIntents
import SwiftUI
import UkatonKit
import WidgetKit

struct UKDeviceDiscoveryWidgetEntryView: View {
    var entry: UKDeviceDiscoveryWidgetProvider.Entry

    @Environment(\.widgetFamily) var family

    private var deviceDiscoveryInformation: UKDeviceDiscoveryInformation { .shared }
    private var isScanning: Bool { deviceDiscoveryInformation.isScanning }
    private var ids: [String] { deviceDiscoveryInformation.ids }

    var spacing: CGFloat = 12

    var systemLargeBody: some View {
        VStack(spacing: spacing + 4) {
            ForEach(0 ..< 6) {
                UKDeviceDiscoveryView(index: $0)
                Divider()
            }
        }
    }

    var systemExtraLargeBody: some View {
        VStack(spacing: spacing + 4) {
            ForEach(0 ..< 6) {
                UKDeviceDiscoveryView(index: $0)
                Divider()
            }
        }
    }

    var uncaughtBody: some View {
        Text("uncaught widget family")
            .unredacted()
    }

    @ViewBuilder
    var scanImage: some View {
        let text = deviceDiscoveryInformation.isScanning ? "stop scan" : "scan"
        let imageName = deviceDiscoveryInformation.isScanning ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash"
        Label(text, systemImage: imageName)
    }

    var body: some View {
        HStack {
            Text("Ukaton Devices")
                .font(.title)
            Spacer()
            Button(intent: UKToggleDeviceScanIntent()) {
                scanImage
            }
        }
        if isScanning {
            HStack {
                Spacer()
                Text("scanning for devices...")
                Spacer()
            }
        }
        if !isScanning, ids.isEmpty {
            HStack {
                Spacer()
                Text("no devices found")
                Spacer()
            }
        }

        switch family {
        case .systemLarge:
            systemLargeBody
        case .systemExtraLarge:
            systemExtraLargeBody
        default:
            uncaughtBody
        }
    }
}
