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
 * @property {string|undefined} connectionType
 */

class UKDiscoveredDevice {
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

    /** @type {string} */
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

    /** @type {string|undefined} */
    #connectionStatus;
    get connectionStatus() {
        return this.#connectionStatus;
    }

    /** @type {string|undefined} */
    #connectionType;
    get connectionType() {
        return this.#connectionType;
    }

    /**
     * @param {DiscoveredDeviceInfo} discoveredDeviceInfo
     */
    constructor(discoveredDeviceInfo) {
        this.update(discoveredDeviceInfo);
    }

    /**
     * @param {DiscoveredDeviceInfo} discoveredDeviceInfo
     */
    update({ id, name, deviceType, rssi, timestampDifference, ipAddress, connectionStatus, connectionType }) {
        this.id = id;
        this.name = name;
        this.deviceType = deviceType;

        this.rssi = rssi;
        this.timestampDifference = timestampDifference;

        this.ipAddress = ipAddress;

        this.connectionStatus = connectionStatus;
        this.connectionType = connectionType;
    }

    connect() {
        // FILL
    }
    disconnect() {
        // FILL
    }
}

export default UKDiscoveredDevice;
