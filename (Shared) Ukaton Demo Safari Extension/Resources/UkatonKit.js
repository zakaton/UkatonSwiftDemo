import UKBluetoothManager from "./UKBluetoothManager.js";
const bluetoothManager = UKBluetoothManager.shared;

// FILL - devices

const UkatonKit = { bluetoothManager };

window.UkatonKit = UkatonKit;

export { bluetoothManager };
