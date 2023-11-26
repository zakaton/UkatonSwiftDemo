import { EventDispatcher } from "./three.module.min.js";
import { Poll, Logger, sendMessage } from "./utils.js";
import UKDiscoveredDevice from "./UKDiscoveredDevice.js";

class UKBluetoothManager {
    logger = new Logger(true);
    eventDispatcher = new EventDispatcher();

    static #shared = new UKBluetoothManager();
    static get shared() {
        return this.#shared;
    }

    #isScanning = false;
    get isScanning() {
        return this.#isScanning;
    }
    set isScanning(newValue) {
        if (this.#isScanning != newValue) {
            this.#isScanning = newValue;
            this.#isScanningPoll.stop();

            this.logger.log(`updated isScanning to ${this.isScanning}`);
            this.eventDispatcher.dispatchEvent({
                type: "isScanning",
                message: { isScanning: this.isScanning },
            });

            if (this.isScanning) {
                this.#discoveredDevicesPoll.start();
            } else {
                this.#discoveredDevicesPoll.stop();
            }
        }
    }

    /**
     * @param {object} message
     * @param {string} message.type
     */
    async #sendMessage(message) {
        return sendMessage(message);
    }

    async checkIsScanning() {
        const response = await this.#sendMessage({ type: "isScanning" });
        const { isScanning } = response;
        this.logger.log(`isScanning response: ${isScanning}`, response);
        this.isScanning = isScanning;
    }

    #isScanningPoll = new Poll(this.checkIsScanning.bind(this), 100);

    async setScan(newValue) {
        if (newValue != this.isScanning) {
            const response = await this.#sendMessage({ type: "setScan", newValue });
            const { isScanning } = response;
            this.logger.log(`setScan response: ${isScanning}`, response);
            if (isScanning == newValue) {
                this.isScanning = isScanning;
            } else {
                this.#isScanningPoll.start();
            }
        } else {
            this.logger.log("redundant setScan");
        }
    }

    #discoveredDevicesPoll = new Poll(this.#checkDiscoveredDevices.bind(this), 200);
    async #checkDiscoveredDevices() {
        const response = await this.#sendMessage({ type: "discoveredDevices" });
        const { discoveredDevices: discoveredDeviceInfo } = response;
        this.logger.log(`discovered ${discoveredDeviceInfo.length} devices`, response);
        this.#updateDiscoveredDevices(discoveredDeviceInfo);
    }

    /** @type {Object.<string, UKDiscoveredDevice>} */
    #discoveredDevices = {};
    get discoveredDevices() {
        return this.#discoveredDevices;
    }

    /**
     * @typedef {import('./UKDiscoveredDevice.js').DiscoveredDeviceInfo} DiscoveredDeviceInfo
     */

    /**
     *
     * @param {[DiscoveredDeviceInfo]} discoveredDevicesInfo
     */
    #updateDiscoveredDevices(discoveredDevicesInfo) {
        const idsToDelete = new Set(Object.keys(this.#discoveredDevices));
        discoveredDevicesInfo.forEach((discoveredDeviceInfo) => {
            const { id } = discoveredDeviceInfo;

            if (idsToDelete.has(id)) {
                idsToDelete.delete(id);
                const discoveredDevice = this.#discoveredDevices[id];
                discoveredDevice.update(discoveredDeviceInfo);
            } else {
                const discoveredDevice = new UKDiscoveredDevice(discoveredDeviceInfo);
                this.#discoveredDevices[id] = discoveredDevice;
            }
        });
        idsToDelete.forEach((id) => {
            this.#discoveredDevices[id].destroy();
            delete this.#discoveredDevices[id];
        });

        this.eventDispatcher.dispatchEvent({
            type: "discoveredDevices",
            message: { discoveredDevices: this.discoveredDevices },
        });
    }

    /** @type {[UKMission]} */
    devices = [];

    /** UKBluetoothManager is a singleton - use UKBluetoothManager.shared */
    constructor() {
        if (this.shared) {
            throw new Error("UKBluetoothManager is a singleton - use UKBluetoothManager.shared");
        }
    }
}

export default UKBluetoothManager;
