import AppIntents
import OSLog
import SwiftUI
import UkatonKit
import UkatonMacros
import WidgetKit

@StaticLogger
struct UKBatteryLevelView: View {
    init(index: Int) {
        deviceInformation = UKDevicesInformation.shared.getInformation(index: index) ?? .none
        logger.debug("UKBatteryLevelView \(index): \(UKDevicesInformation.shared.ids, privacy: .public)")
    }

    init(id: String) {
        deviceInformation = UKDevicesInformation.shared.getInformation(id: id) ?? .none
        logger.debug("UKBatteryLevelView \(id): \(UKDevicesInformation.shared.ids, privacy: .public)")
    }

    init() {
        self.init(index: 0)
    }

    var link: URL {
        .init(string: "ukaton-demo://select-device?id=\(deviceInformation.id)")!
    }

    var emoji: String {
        switch deviceType {
        case .motionModule:
            "📦"
        case .leftInsole, .rightInsole:
            "👟"
        }
    }

    var deviceInformation: UKDeviceInformation
    var batteryLevel: UKBatteryLevel {
        deviceInformation.batteryLevel
    }

    var batteryLevelProgress: Double {
        guard !isNone else { return .zero }
        return .init(batteryLevel) / 100
    }

    var batteryLevelView: some View {
        if !isNone {
            Text("\(batteryLevel)%")
        }
        else {
            Text(" ")
        }
    }

    var batteryLevelImageString: String {
        guard !isNone else { return "" }
        guard !isCharging else { return "battery.100.bolt" }

        return switch batteryLevel {
        case 85 ... 100:
            "battery.100"
        case 65 ... 85:
            "battery.75"
        case 35 ... 65:
            "battery.50"
        case 15 ... 35:
            "battery.25"
        default:
            "battery.0"
        }
    }

    var batteryLevelColor: Color {
        guard !deviceInformation.isNone else { return .gray }

        return switch batteryLevel {
        case 60 ... 100:
            .green
        case 10 ... 60:
            .orange
        case 0 ... 10:
            .red
        default:
            .red
        }
    }

    var batteryLevelImage: some View {
        Image(systemName: batteryLevelImageString)
            .foregroundColor(batteryLevelColor)
    }

    var isCharging: Bool {
        deviceInformation.isCharging
    }

    var deviceType: UKDeviceType {
        deviceInformation.deviceType
    }

    var isNone: Bool {
        deviceInformation.isNone
    }

    var name: String {
        deviceInformation.name
    }

    @Environment(\.widgetFamily) var family

    var imageName: String? {
        guard !deviceInformation.isNone else { return nil }

        return switch deviceType {
        case .leftInsole, .rightInsole:
            "shoe.fill"
        default:
            "rotate.3d.fill"
        }
    }

    private var imageScale: Image.Scale {
        switch family {
        case .accessoryCircular:
            .large
        case .accessoryCorner:
            .small
        case .accessoryRectangular:
            .small

        case .systemSmall:
            #if os(iOS)
                .medium
            #else
                .large
            #endif

        case .systemMedium, .systemLarge, .systemExtraLarge:
            .large

        default:
            .medium
        }
    }

    @ViewBuilder
    private var image: some View {
        Image(systemName: imageName ?? "")
            .imageScale(imageScale)
            .modify {
                if deviceType == .leftInsole {
                    $0.scaleEffect(x: -1)
                }
            }
    }

    var body: some View {
        if deviceInformation.isNone {
            _body
        }
        else {
            Link(destination: link) {
                _body
                    .modify {
                        #if os(watchOS)
                            $0.widgetURL(link)
                        #endif
                    }
            }
        }
    }

    var circleBody: some View {
        ZStack {
            image

            ProgressView(value: .init(batteryLevelProgress))
                .progressViewStyle(.circular)
                .tint(batteryLevelColor)
            if isCharging {
                VStack {
                    Image(systemName: "bolt.fill")
                        .imageScale(.medium)
                        .offset(y: -5)
                    Spacer()
                }
            }
        }
    }

    @ViewBuilder
    var _body: some View {
        switch family {
        case .accessoryInline:
            if !isNone {
                HStack {
                    image
                    Text("\(name) \(batteryLevel)%")
                }
            }
        case .accessoryCorner:
            HStack {
                if !isNone {
                    Label("\(batteryLevel)%", systemImage: imageName ?? "")
                        .tint(batteryLevelColor)
                        .minimumScaleFactor(0.5)
                }
            }
            .widgetCurvesContent()
            .widgetLabel {
                ProgressView(value: .init(batteryLevelProgress))
                    .tint(batteryLevelColor)
            }
        case .accessoryRectangular:
            if false {
                VStack {
                    HStack {
                        image
                        batteryLevelView
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    HStack {
                        Text("\(name)")
                        Spacer()
                    }
                    ProgressView(value: .init(batteryLevelProgress))
                        .tint(batteryLevelColor)
                        .modify {
                            #if os(iOS)
                                $0.scaleEffect(x: 1, y: 2, anchor: .center)
                            #else
                            #endif
                        }
                }
            }
            else {
                VStack {
                    circleBody
                    batteryLevelView
                }
            }
        case .systemSmall, .accessoryCircular:
            circleBody
        case .systemMedium:
            VStack(spacing: 12) {
                circleBody
                batteryLevelView
                    .font(.title)
            }
        case .systemLarge, .systemExtraLarge:
            HStack {
                image
                Text("\(name)")
                Spacer()
                batteryLevelView
                batteryLevelImage
            }
            .font(.subheadline)

        default:
            Text("uncaught family \(family.debugDescription)")
        }
    }
}
