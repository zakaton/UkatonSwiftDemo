class Logger {
    /**
     *
     * @param {boolean} isEnabled
     * @param {string|undefined} suffix
     */
    constructor(isEnabled = true, suffix) {
        this.isEnabled = isEnabled;
        this.#suffix = suffix;
    }

    isEnabled = true;
    /** @type {string|undefined} */
    #suffix;

    /**
     *
     * @param {string} label
     * @param  {...any} rest
     */
    log(label, ...rest) {
        if (this.isEnabled) {
            console.groupCollapsed(`[${this.constructor.name}]${this.#suffix ? `(${this.#suffix})` : ""} - ${label}`);
            if (rest.length > 0) {
                console.log(...rest);
            }
            console.trace(); // hidden in collapsed group
            console.groupEnd();
        }
    }
}

class Poll {
    logger = new Logger(true);

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

function is_iOS() {
    return (
        ["iPad Simulator", "iPhone Simulator", "iPod Simulator", "iPad", "iPhone", "iPod"].includes(
            navigator.platform
        ) ||
        // iPad on iOS 13 detection
        (navigator.userAgent.includes("Mac") && "ontouchend" in document)
    );
}

/**
 * @param {object} message
 * @param {string} message.type
 */
async function sendMessage(message) {
    // TODO - distinguish between popup/content.js and background.js
    if (true) {
        return browser.runtime.sendMessage(message);
    } else {
        const promise = new Promise((resolve) => {
            browser.runtime.sendNativeMessage("application.id", message, (response) => {
                resolve(response);
            });
        });
        return promise;
    }
}

export { Poll, Logger, is_iOS, sendMessage };
