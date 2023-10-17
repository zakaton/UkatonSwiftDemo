//
//  BluetoothTestView.swift
//  UkatonSwiftDemo
//
//  Created by Zack Qattan on 10/17/23.
//

import CoreBluetooth
import SwiftUI

class BluetoothViewModel: NSObject, ObservableObject {
    private var centralManager: CBCentralManager!
    private var peripherals: [CBPeripheral] = []
    @Published var peripheralNames: [String] = []

    override init() {
        super.init()
        self.centralManager = .init(delegate: self, queue: .main)
    }
}

extension BluetoothViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil)
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
}
