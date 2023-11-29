import Combine
import OSLog
import SafariServices
import UkatonKit
import UkatonMacros

typealias UKSensorDataJson = [String: [String: Any]]

@StaticLogger
struct UKSensorDataFlags {
    var motion: Set<UKMotionDataType> = .init()
    var pressure: Set<UKPressureDataType> = .init()

    private var isEmpty: Bool {
        motion.isEmpty && pressure.isEmpty
    }

    mutating func json(mission: UKMission) -> UKSensorDataJson? {
        guard !isEmpty else { return nil }

        var json: UKSensorDataJson = [:]

        if !motion.isEmpty {
            var motionJson: [String: Any] = .init()
            motion.forEach { motionDataType in
                motionJson[spacesToCamelCase(motionDataType.name)] = mission.sensorData.motion.json(motionDataType: motionDataType)
            }
            json["motion"] = motionJson
            motion.removeAll(keepingCapacity: true)
        }

        if !pressure.isEmpty {
            var pressureJson: [String: Any] = .init()
            pressure.forEach { pressureDataType in
                pressureJson[spacesToCamelCase(pressureDataType.name)] = mission.sensorData.pressure.json(pressureDataType: pressureDataType)
            }
            json["pressure"] = pressureJson
            pressure.removeAll(keepingCapacity: true)
        }

        logger.log("sensorData \(json)")
        return json
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

@StaticLogger()
class SafariWebExtension {
    static let shared = SafariWebExtension()

    var bluetoothManager: UKBluetoothManager { .shared }
    var missionsManager: UKMissionsManager { .shared }
    var cancellables: Set<AnyCancellable> = .init()

    private let now: Date = .now
    private var lastTimeUpdatedDiscoveredDevices: Date = .now
    var timeSinceUpdatedDiscoveredDevices: TimeInterval {
        lastTimeUpdatedDiscoveredDevices.timeIntervalSince(now)
    }

    private var lastTimeUpdatedIsScanning: Date = .now
    var timeSinceUpdatedIsScanning: TimeInterval {
        lastTimeUpdatedIsScanning.timeIntervalSince(now)
    }

    private var lastTimeMissionsUpdatedSensorDataConfigurations: [String: Date] = [:]
    func timeSinceMissionUpdatedSensorDataConfigurations(mission: UKMission) -> TimeInterval {
        guard let lastTimeMissionUpdatedSensorDataConfigurations = lastTimeMissionsUpdatedSensorDataConfigurations[mission.id] else {
            return .zero
        }
        return lastTimeMissionUpdatedSensorDataConfigurations.timeIntervalSince(now)
    }

    private var missionsSensorDataFlags: [String: UKSensorDataFlags] = [:]
    func getJson(mission: UKMission) -> UKSensorDataJson? {
        missionsSensorDataFlags[mission.id]?.json(mission: mission)
    }

    init() {
        bluetoothManager.discoveredDevicesSubject
            .sink(receiveValue: { [self] _ in
                lastTimeUpdatedDiscoveredDevices = .now
            }).store(in: &cancellables)

        bluetoothManager.isScanningSubject
            .sink(receiveValue: { [self] _ in
                lastTimeUpdatedIsScanning = .now
            }).store(in: &cancellables)

        missionsManager.missionAddedSubject.sink(receiveValue: { [self] mission in
            missionsSensorDataFlags[mission.id] = .init()
            mission.sensorData.motion.dataSubject.sink(receiveValue: { [self] motionDataType in
                missionsSensorDataFlags[mission.id]?.motion.insert(motionDataType)
            }).store(in: &cancellables)
            mission.sensorData.pressure.dataSubject.sink(receiveValue: { [self] pressureDataType in
                missionsSensorDataFlags[mission.id]?.pressure.insert(pressureDataType)
            }).store(in: &cancellables)

            mission.sensorDataConfigurationsSubject.sink(receiveValue: { [self, mission] _ in
                lastTimeMissionsUpdatedSensorDataConfigurations[mission.id] = .now
            }).store(in: &cancellables)
        }).store(in: &cancellables)

        missionsManager.missionRemovedSubject.sink(receiveValue: { [self] mission in
            lastTimeMissionsUpdatedSensorDataConfigurations.removeValue(forKey: mission.id)
            missionsSensorDataFlags.removeValue(forKey: mission.id)
        }).store(in: &cancellables)
    }
}

@StaticLogger()
class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    var bluetoothManager: UKBluetoothManager { .shared }
    var safariWebExtension: SafariWebExtension { .shared }

    func getDiscoveredDeviceIndex(id: String) -> Int? {
        bluetoothManager.discoveredDevices.firstIndex(where: { $0.id?.uuidString == id })
    }

    func getMission(id: String) -> UKMission? {
        guard let discoveredDevice = bluetoothManager.discoveredDevices.first(where: { $0.id?.uuidString == id }) else { return nil }
        return discoveredDevice.mission
    }

    func beginRequest(with context: NSExtensionContext) {
        guard let item = context.inputItems.first as? NSExtensionItem,
              let userInfo = item.userInfo as? [String: Any],
              let messageData = userInfo[SFExtensionMessageKey]
        else {
            context.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }

        guard let message = messageData as? [String: Any] else {
            logger.error("invalid message")
            return
        }

        logger.debug("\(String(describing: message), privacy: .public)")

        let response = NSExtensionItem()

        let timestamp = message["timestamp"] as? Double

        guard let messageType = message["type"] as? String else {
            logger.error("no message type defined")
            return
        }

        switch messageType {
        case "setScan":
            logger.debug("set scan")
            if let newIsScanning = message["newValue"] as? Bool {
                if newIsScanning {
                    bluetoothManager.scanForDevices()
                }
                else {
                    bluetoothManager.stopScanningForDevices()
                }
            }
            else {
                logger.error("undefined newValue")
            }
            response.userInfo = [SFExtensionMessageKey: [
                "isScanning": bluetoothManager.isScanning,
                "timestamp": safariWebExtension.timeSinceUpdatedIsScanning
            ]]
        case "isScanning":
            logger.debug("check isScanning")
            if timestamp != safariWebExtension.timeSinceUpdatedIsScanning {
                response.userInfo = [SFExtensionMessageKey: [
                    "isScanning": bluetoothManager.isScanning,
                    "timestamp": safariWebExtension.timeSinceUpdatedIsScanning
                ]]
            }
        case "discoveredDevices":
            logger.debug("request discovered devices")
            if timestamp != safariWebExtension.timeSinceUpdatedDiscoveredDevices {
                response.userInfo = [SFExtensionMessageKey: [
                    "discoveredDevices": bluetoothManager.discoveredDevices.map {
                        var discoveredDeviceInfo: [String: Any] = [
                            "name": $0.name,
                            "deviceType": $0.deviceType.name,
                            "rssi": $0.rssi?.intValue ?? 0,
                            "id": $0.id?.uuidString ?? "",
                            "timestampDifference": $0.timestampDifference_ms,
                            "connectionStatus": $0.mission.connectionStatus.name
                        ]
                        if $0.isConnectedToWifi, let ipAddress = $0.ipAddress {
                            discoveredDeviceInfo["ipAddress"] = ipAddress
                        }
                        if let connectionType = $0.mission.connectionType {
                            discoveredDeviceInfo["connectionType"] = connectionType.name
                        }
                        return discoveredDeviceInfo
                    },
                    "timestamp": safariWebExtension.timeSinceUpdatedDiscoveredDevices
                ]]
            }

        case "connect":
            if let id = message["id"] as? String,
               let discoveredDeviceIndex = getDiscoveredDeviceIndex(id: id),
               let connectionTypeString = message["connectionType"] as? String,
               let connectionType: UKConnectionType = .init(from: connectionTypeString)
            {
                bluetoothManager.discoveredDevices[discoveredDeviceIndex].connect(type: connectionType)
            }
            else {
                logger.error("no discoveredDevice found in \(messageType, privacy: .public) message")
            }
        case "disconnect":
            if let id = message["id"] as? String,
               let discoveredDeviceIndex = getDiscoveredDeviceIndex(id: id)
            {
                bluetoothManager.discoveredDevices[discoveredDeviceIndex].disconnect()
            }
            else {
                logger.error("no discoveredDevice found in \(messageType, privacy: .public) message")
            }

        case "connectionStatus":
            if let id = message["id"] as? String,
               let mission = getMission(id: id)
            {
                var message: [String: Any] = [
                    "connectionStatus": mission.connectionStatus.name
                ]
                if let connectionType = mission.connectionType {
                    message["connectionType"] = connectionType.name
                }

                response.userInfo = [SFExtensionMessageKey: message]
            }
            else {
                logger.error("no mission found in \(messageType, privacy: .public) message")
            }
        case "getSensorDataConfigurations":
            logger.debug("request sensorDataConfigurations")
            if let id = message["id"] as? String,
               let mission = getMission(id: id),
               timestamp != safariWebExtension.timeSinceMissionUpdatedSensorDataConfigurations(mission: mission)
            {
                let message: [String: Any] = [
                    "sensorDataConfigurations": mission.sensorDataConfigurations.json,
                    "timestamp": safariWebExtension.timeSinceMissionUpdatedSensorDataConfigurations(mission: mission)
                ]

                response.userInfo = [SFExtensionMessageKey: message]
            }
            else {
                logger.error("no mission found in \(messageType, privacy: .public) message")
            }
        case "setSensorDataConfigurations":
            if let id = message["id"] as? String,
               let mission = getMission(id: id)
            {
                if let sensorDataConfigurationsJson = message["sensorDataConfigurations"] as? [String: [String: UKSensorDataRate]] {
                    logger.log("sensorDataConfigurationsJson, \(sensorDataConfigurationsJson.debugDescription, privacy: .public)")
                    let sensorDataConfigurations: UKSensorDataConfigurations = .init(from: sensorDataConfigurationsJson)
                    print(sensorDataConfigurations)
                    try? mission.setSensorDataConfigurations(sensorDataConfigurations)
                }
                else {
                    logger.error("no sensorDataConfigurations found in message")
                }
            }
            else {
                logger.error("no mission found in \(messageType, privacy: .public) message")
            }
        case "sensorData":
            if let id = message["id"] as? String,
               let mission = getMission(id: id),
               let sensorData = safariWebExtension.getJson(mission: mission)
            {
                let message: [String: Any] = [
                    "sensorData": sensorData,
                    "timestamp": mission.sensorData.timestamp
                ]

                response.userInfo = [SFExtensionMessageKey: message]
            }
            else {
                logger.error("no mission found in \(messageType, privacy: .public) message")
            }
        case "vibrate":
            if let vibrationType = message["vibrationType"] as? String,
               let vibration = message["vibration"] as? [Any],
               let id = message["id"] as? String,
               let mission = getMission(id: id)
            {
                switch vibrationType {
                case "waveforms":
                    if let waveformArray = vibration as? [[String: Double]] {
                        let waveforms: [UKVibrationWaveform] = waveformArray.map {
                            .init(
                                intensity: .init($0["intensity"] ?? 0),
                                delay: .init($0["delay"] ?? 0)
                            )
                        }
                        logger.debug("waveforms: \(waveforms, privacy: .public)")
                        try? mission.vibrate(waveforms: waveforms)
                    }
                case "waveformEffects":
                    if let waveformEffectsArray = vibration as? [Double] {
                        let waveformEffects: [UKVibrationWaveformEffect] = waveformEffectsArray.map {
                            .init(rawValue: .init($0)) ?? .none
                        }
                        logger.debug("waveformEffects: \(waveformEffects, privacy: .public)")
                        try? mission.vibrate(waveformEffects: waveformEffects)
                    }
                default:
                    logger.error("uncaught vibration type \(vibrationType, privacy: .public)")
                }
            }
            else {
                logger.error("no mission found in \(messageType, privacy: .public) message")
            }
        default:
            logger.warning("uncaught exception for message type \(messageType)")
            response.userInfo = [SFExtensionMessageKey: ["echo": message]]
        }

        context.completeRequest(returningItems: [response], completionHandler: nil)
    }
}
