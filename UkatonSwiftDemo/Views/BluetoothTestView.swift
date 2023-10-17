//
//  BluetoothTestView.swift
//  UkatonSwiftDemo
//
//  Created by Zack Qattan on 10/17/23.
//

import CoreBluetooth
import SwiftUI

class BluetoothViewModel: NSObject, ObservableObject {
    static func generateUUID(value: String) -> CBUUID {
        .init(string: "5691eddf-\(value)-4420-b7a5-bb8751ab5181")
    }

    enum ServiceUUID: String {
        case main = "0000"
        var uuid: CBUUID {
            generateUUID(value: rawValue)
        }
    }

    enum CharacteristicUUID: String {
        case sensorData = "0000"
        var uuid: CBUUID {
            generateUUID(value: rawValue)
        }
    }

    private var centralManager: CBCentralManager!
    private var peripherals: [CBPeripheral] = []
    @Published var peripheralNames: [String] = []

    override init() {
        super.init()
        // self.centralManager = .init(delegate: self, queue: .main)
    }
}

extension BluetoothViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [ServiceUUID.main.uuid])
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
            peripheralNames.append(peripheral.name ?? "unnamed device")
        }
    }
}

struct BluetoothTestView: View {
    @StateObject private var bluetoothViewModel = BluetoothViewModel()

    var body: some View {
        NavigationStack {
            List(bluetoothViewModel.peripheralNames, id: \.self) { peripheralName in
                Text(peripheralName)
            }
            .navigationTitle("Bluetooth Devices")
        }
    }
}

#Preview {
    BluetoothTestView()
        .frame(maxWidth: 300)
}
