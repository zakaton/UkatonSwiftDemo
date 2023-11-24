// DISCOVERED DEVICES
/**
 * @typedef UKDiscoveredDevice
 * @type {object}
 * @property {string} id
 * @property {string} name
 * @property {number} deviceType
 * @property {boolean} isConnected
 * @property {number} rssi
 * @property {HTMLElement|undefined} container
 * @property {string|undefined} ipAddress
 * @property {number} timestampDifference
 * @property {boolean|undefined} shouldRemove
 */

class UKMission {}

const UkatonKit = {
    /** @type {Object.<string, UKDiscoveredDevice>} */
    discoveredDevices: {},

    /** @type {[UKMission]} */
    devices: [],
};
