import EventDispatcher from "./EventDispatcher.js";
import UKMission from "./UKMission.js";
import { Logger, addBackgroundListener } from "./utils.js";

export default class UKDeviceManager {
    logger = new Logger(false, this);
    eventDispatcher = new EventDispatcher();

    static #shared = new UKDeviceManager();
    static get shared() {
        return this.#shared;
    }

    /** @type {[UKMission]} */
    #devices = [];
    get devices() {
        return this.#devices;
    }

    /** UKDeviceManager is a singleton - use UKDeviceManager.shared */
    constructor() {
        if (this.shared) {
            throw new Error("UKDeviceManager is a singleton - use UKDeviceManager.shared");
        }

        addBackgroundListener(this.#onBackgroundMessage.bind(this));
    }

    /**
     * @param {object} message
     * @param {string} message.type
     */
    #onBackgroundMessage(message) {
        this.logger.log(`received background message of type ${message.type}`, message);
        switch (message.type) {
            default:
                this.logger.log(`uncaught message type ${message.typs}`);
                break;
        }
    }
}
