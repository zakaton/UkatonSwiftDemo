import UKDiscoveredDevice from "./UKDiscoveredDevice.js";
import { LitElement } from "./lit-all.min.js";

export class DiscoveredDeviceController {
    host;

    /** @type {UKDiscoveredDevice} */
    discoveredDevice;

    messageTypes = [
        "name",
        "deviceType",

        "connectionStatus",
        "connectionType",

        "rssi",
        "ipAddress",
        "timestampDifference",
    ];

    /**
     *
     * @param {LitElement} host
     * @param {UKDiscoveredDevice} discoveredDevice
     */
    constructor(host, discoveredDevice) {
        this.discoveredDevice = discoveredDevice;
        this._requestUpdate = this._requestUpdate.bind(this);
        (this.host = host).addController(this);
        console.log("A", host, discoveredDevice);
    }

    _requestUpdate() {
        this.host.requestUpdate();
    }

    hostConnected() {
        this.messageTypes.forEach((type) => {
            this.discoveredDevice.eventDispatcher.addEventListener(type, this._requestUpdate);
        });
    }

    hostDisconnected() {
        this.messageTypes.forEach((type) => {
            this.discoveredDevice.eventDispatcher.removeEventListener(type, this._requestUpdate);
        });
    }
}
