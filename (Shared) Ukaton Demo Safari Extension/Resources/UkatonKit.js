function iOS() {
    return (
        ["iPad Simulator", "iPhone Simulator", "iPod Simulator", "iPad", "iPhone", "iPod"].includes(
            navigator.platform
        ) ||
        // iPad on iOS 13 detection
        (navigator.userAgent.includes("Mac") && "ontouchend" in document)
    );
}

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
 * @property {Poll} isConnectedPoll
 */

class UKMission {}

const UkatonKit = {
    /** @type {Object.<string, UKDiscoveredDevice>} */
    discoveredDevices: {},

    /** @type {[UKMission]} */
    devices: [],
};
