import UKDiscoveredDevice from "./UKDiscoveredDevice.js";
import { LitElement } from "./lit-all.min.js";

export default class UKDiscoveredDeviceController {
    host;

    /** @type {UKDiscoveredDevice} */
    discoveredDevice;

    /**
     *
     * @param {LitElement} host
     * @param {UKDiscoveredDevice} discoveredDevice
     */
    constructor(host, discoveredDevice) {
        this.discoveredDevice = discoveredDevice;
        this._requestUpdate = this._requestUpdate.bind(this);
        (this.host = host).addController(this);
    }

    _requestUpdate() {
        this.host.requestUpdate();
    }

    hostConnected() {
        this.discoveredDevice.eventDispatcher.addEventListener("updated", this._requestUpdate);
    }

    hostDisconnected() {
        this.discoveredDevice.eventDispatcher.removeEventListener("updated", this._requestUpdate);
    }
}
