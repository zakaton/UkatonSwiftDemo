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

    @ViewBuilder
    var scanButton: some View {
        let text = deviceDiscoveryInformation.isScanning ? "scanning" : "scan"
        let imageName = deviceDiscoveryInformation.isScanning ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash"
        let label = Label(text, systemImage: imageName)
            .labelStyle(.iconOnly)
        let intent = UKToggleDeviceScanIntent()
        Button(intent: intent) {
            label
        }
    }

    var body: some View {
        HStack {
            Text("Ukaton Devices")
                .font(.title2)
            Spacer()
            scanButton
        }

        if isScanning {
            HStack {
                Spacer()
                Text("scanning for devices...")
                    .font(.caption)
                Spacer()
            }
        }
        if ids.isEmpty {
            if !isScanning {
                HStack {
                    Spacer()
                    Text("no devices found")
                        .font(.caption)
                    Spacer()
                }
            }
        }
        if !ids.isEmpty {
            VStack {
                ForEach(ids, id: \.self) {
                    UKDeviceDiscoveryRow(id: $0)
                    Divider()
                }
            }
        }
        Spacer()
    }
}
