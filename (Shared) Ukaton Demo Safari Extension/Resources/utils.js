class Logger {
    /**
     *
     * @param {boolean} isEnabled
     * @param {any} host
     * @param {string|undefined} suffix
     */
    constructor(isEnabled, host, suffix) {
        this.isEnabled = isEnabled;
        this.#host = host;
        this.#suffix = suffix;
    }

    isEnabled = true;
    /** @type {any} */
    #host;
    /** @type {string|undefined} */
    #suffix;

    /**
     *
     * @param {string} label
     * @param  {...any} rest
     */
    log(label, ...rest) {
        if (this.isEnabled) {
            console.groupCollapsed(
                `[${this.#host.constructor.name}]${this.#suffix ? `(${this.#suffix})` : ""} - ${label}`
            );
            if (rest.length > 0) {
                console.log(...rest);
            }
            console.trace(); // hidden in collapsed group
            console.groupEnd();
        }
    }
}

class Poll {
    logger = new Logger(false, this);

    /**
     *
     * @param {function():void} callback
     * @param {number} interval
     */
    constructor(callback, interval) {
        this.#callback = callback;
        this.#interval = interval;
    }

    /** @type {function():void} */
    #callback;
    /** @type {number} */
    #interval;
    /** @type {number|null} */
    #intervalId = null;

    get isRunning() {
        return this.#intervalId != null;
    }

    start() {
        if (!this.isRunning) {
            this.logger.log("starting poll");
            this.#intervalId = setInterval(() => this.#callback(), this.#interval);
        }
    }
    stop() {
        if (this.isRunning) {
            this.logger.log("stopping poll");
            clearInterval(this.#intervalId);
            this.#intervalId = null;
        }
    }
}

function check_is_iOS() {
    return (
        ["iPad Simulator", "iPhone Simulator", "iPod Simulator", "iPad", "iPhone", "iPod"].includes(
            navigator.platform
        ) ||
        // iPad on iOS 13 detection
        (navigator.userAgent.includes("Mac") && "ontouchend" in document)
    );
}
const is_iOS = check_is_iOS();

/**
 * @param {object} message
 * @param {string} message.type
 */
async function sendBackgroundMessage(message) {
    return browser.runtime.sendMessage(message);
}

/**
 * @param {function():void} callback
 */
function addBackgroundListener(callback) {
    browser.runtime.onMessage.addListener(callback);
}

/**
 * @param {function():void} callback
 */
function removeBackgroundListener(callback) {
    browser.runtime.onMessage.removeListener(callback);
}

export { Poll, Logger, is_iOS, sendBackgroundMessage, addBackgroundListener, removeBackgroundListener };
