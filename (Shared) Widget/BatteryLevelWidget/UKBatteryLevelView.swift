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
        // logger.debug("UKBatteryLevelView \(index)")
    }

    init(id: String) {
        deviceInformation = UKDevicesInformation.shared.getInformation(id: id) ?? .none
        // logger.debug("UKBatteryLevelView \(id)")
    }

    init() {
        self.init(index: 0)
    }

    var id: String {
        deviceInformation.id
    }

    var link: URL {
        .init(string: "ukaton-demo://select-device?id=\(id)")!
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

    var batteryLevelImageString: String? {
        guard !isNone else { return nil }
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
        guard !isNone else { return .gray }

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

    @ViewBuilder
    var batteryLevelImage: some View {
        if let batteryLevelImageString {
            Image(systemName: batteryLevelImageString)
                .foregroundColor(batteryLevelColor)
        }
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
        guard !isNone else { return nil }

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
        if let imageName {
            Image(systemName: imageName)
                .imageScale(imageScale)
                .modify {
                    if deviceType == .leftInsole {
                        $0.scaleEffect(x: -1)
                    }
                }
        }
    }

    var body: some View {
        if isNone {
            _body
        }
        else {
            Link(destination: link) {
                _body
//                    .modify {
//                        #if os(watchOS)
//                            $0.widgetURL(link)
//                        #endif
//                    }
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
        .modify {
            #if os(watchOS)
                $0.widgetLabel {
                    Text("\(name)")
                }
            #endif
        }
    }

    @ViewBuilder
    var _body: some View {
        switch family {
        case .accessoryInline:
            if !isNone {
                HStack {
                    image
                    if isCharging {
                        Image(systemName: "bolt.fill")
                    }
                    Text("\(name) \(batteryLevel)%")
                }
            }
        case .accessoryCorner:
            HStack {
                if !isNone {
                    Text("\(emoji) \(batteryLevel)%")
                        .tint(batteryLevelColor)
                        .minimumScaleFactor(0.5)
                }
            }
            .modify {
                #if os(watchOS)
                    $0.widgetCurvesContent()
                        .widgetLabel {
                            ProgressView(value: .init(batteryLevelProgress))
                                .tint(batteryLevelColor)
                        }
                #endif
            }
        case .accessoryRectangular:
            if UKBatteryLevelWidgetEntryView.onlyShowSingleViewForAccessoryRectangular {
                if !isNone {
                    VStack {
                        HStack {
                            image
                            if isCharging {
                                Image(systemName: "bolt.fill")
                            }
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
                                        .offset(y: -2)
                                #else
                                #endif
                            }
                        Spacer()
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
