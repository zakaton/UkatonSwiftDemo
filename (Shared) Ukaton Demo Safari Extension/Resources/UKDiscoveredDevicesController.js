import { bluetoothManager } from "./UkatonKit.js";

export default class UKDiscoveredDevicesController {
    host;

    constructor(host) {
        (this.host = host).addController(this);
        this._onDiscoveredDevicesUpdate = this._onDiscoveredDevicesUpdate.bind(this);
    }

    _onDiscoveredDevicesUpdate() {
        this.host.requestUpdate();
    }

    hostConnected() {
        bluetoothManager.eventDispatcher.addEventListener("discoveredDevices", this._onDiscoveredDevicesUpdate);
    }

    hostDisconnected() {
        bluetoothManager.eventDispatcher.removeEventListener("discoveredDevices", this._onDiscoveredDevicesUpdate);
    }
}
