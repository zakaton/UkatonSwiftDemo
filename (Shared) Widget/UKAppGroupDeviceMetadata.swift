import UkatonKit

protocol UKAppGroupDeviceMetadata: Identifiable {
    var id: String { get }
    var name: String { get }
    var deviceType: UKDeviceType { get }
    var isConnectedToWifi: Bool { get }
    var ipAddress: String? { get }
    var connectionStatus: UKConnectionStatus { get }
    var connectionType: UKConnectionType? { get }
}

extension UKAppGroupDeviceMetadata {
    var isConnected: Bool { connectionStatus == .connected }
}
