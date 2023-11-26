import { is_iOS, Logger, sendMessage, Poll } from "./utils.js";
import { EventDispatcher } from "./three.module.min.js";

/** @typedef {"motion module" | "left insole" | "right insole"} UKDevicetype */
/** @typedef {"bluetooth" | "udp"} UKConnectionType */
/** @typedef {"not connected" | "connecting" | "connected" | "disconnecting"} UKConnectionStatus */

/**
 * @typedef DiscoveredDeviceInfo
 * @type {object}
 * @property {string} id
 * @property {string} name
 * @property {number} deviceType
 *
 * @property {number} timestampDifference
 * @property {number} rssi
 * @property {string|undefined} ipAddress
 *
 * @property {string} connectionStatus
 * @property {UKConnectionType|undefined} connectionType
 */

class UKDiscoveredDevice {
    eventDispatcher = new EventDispatcher();

    /** @type {string} */
    #id;
    get id() {
        return this.#id;
    }

    /** @type {string} */
    #name;
    get name() {
        return this.#name;
    }

    /** @type {UKDevicetype} */
    #deviceType;
    get deviceType() {
        return this.#deviceType;
    }

    /** @type {number} */
    #rssi;
    get rssi() {
        return this.#rssi;
    }

    /** @type {number} */
    #timestampDifference;
    get timestampDifference() {
        return this.#timestampDifference;
    }

    /** @type {string|undefined} */
    #ipAddress;
    get ipAddress() {
        return this.#ipAddress;
    }
    get isConnectedToWifi() {
        return Boolean(this.ipAddress);
    }

    /** @type {UKConnectionStatus|undefined} */
    #connectionStatus;
    get connectionStatus() {
        return this.#connectionStatus;
    }
    set connectionStatus(newValue) {
        if (this.#connectionStatus != newValue) {
            this.#connectionStatus = newValue;
            if (newValue == "connected" || newValue == "not connected") {
                this.#connectionStatusPoll.stop();
            }
            this.logger.log(`new connection status: ${this.connectionStatus}`);
            this.eventDispatcher.dispatchEvent({ type: "connectionStatus", connectionStatus: this.connectionStatus });
        }
    }
    get isConnected() {
        return this.connectionStatus == "connected";
    }

    /** @type {UKConnectionType|undefined} */
    #connectionType;
    get connectionType() {
        return this.#connectionType;
    }

    /**
     * @param {DiscoveredDeviceInfo} discoveredDeviceInfo
     */
    constructor(discoveredDeviceInfo) {
        this.logger = new Logger(true, this, discoveredDeviceInfo.id);
        this.update(discoveredDeviceInfo);
    }

    /**
     * @param {DiscoveredDeviceInfo} discoveredDeviceInfo
     */
    update(discoveredDeviceInfo) {
        const { id, name, deviceType, rssi, timestampDifference, ipAddress, connectionStatus, connectionType } =
            discoveredDeviceInfo;

        this.#id = id;
        this.#name = name;
        this.#deviceType = deviceType;

        this.#rssi = rssi;
        this.#timestampDifference = timestampDifference;

        this.#ipAddress = ipAddress;

        this.#connectionStatus = connectionStatus;
        this.#connectionType = connectionType;

        this.logger.log(`updated discovered device ${id}`, discoveredDeviceInfo);
    }

    /**
     *
     * @param {object} message
     * @param {string} message.type
     */
    async #sendMessage(message) {
        Object.assign(message, { id: this.id });
        return sendMessage(message);
    }

    #connectionStatusPoll = new Poll(this.#checkConectionStatus.bind(this), 200);
    async #checkConectionStatus() {
        await this.#sendMessage({ type: "connectionStatus" });
    }

    /**
     * @param {UKConnectionType} connectionType
     */
    async connect(connectionType = "bluetooth") {
        if (this.connectionStatus == "connected") {
            this.logger.log("can't connect - already connected");
            return;
        }
        if (connectionType != "bluetooth" && is_iOS()) {
            this.logger.log(`unable to connect via ${connectionType} on iOS - changing to bluetooth`);
            connectionType = "bluetooth";
        }
        await this.#sendMessage({ type: "connect", connectionType });
        this.#connectionStatusPoll.start();
    }
    async disconnect() {
        if (this.connectionStatus == "not connected") {
            this.logger.log("can't disconnect - not connected");
            return;
        }
        await this.#sendMessage({ type: "disconnect" });
        this.#connectionStatusPoll.start();
    }

    /**
     * @param {object} message
     * @param {string} message.type
     */
    onBackgroundMessage(message) {
        this.logger.log(`received background message of type ${message.type}`, message);
        switch (message.type) {
            case "connectionStatus":
                this.connectionStatus = message.connectionStatus;
                break;
            default:
                this.logger.log(`uncaught message type ${message.typs}`);
                break;
        }
    }

    destroy() {
        this.#connectionStatusPoll.stop();
    }
}

export default UKDiscoveredDevice;
