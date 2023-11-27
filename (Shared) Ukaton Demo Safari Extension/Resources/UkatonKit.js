import UKBluetoothManager from "./UKBluetoothManager.js";
import UKDeviceManager from "./UKDeviceManager.js";

const bluetoothManager = UKBluetoothManager.shared;
const deviceManager = UKDeviceManager.shared;

const UkatonKit = { bluetoothManager, deviceManager };

window.UkatonKit = UkatonKit;

export { bluetoothManager, deviceManager };
