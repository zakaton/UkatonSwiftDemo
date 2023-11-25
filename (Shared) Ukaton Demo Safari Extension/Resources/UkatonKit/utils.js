class Logger {
    constructor(isEnabled = true) {
        this.isEnabled = isEnabled;
    }

    isEnabled = true;

    /**
     *
     * @param {string} label
     * @param  {...any} rest
     */
    log(label, ...rest) {
        if (this.isEnabled) {
            console.groupCollapsed(`[${this.constructor.name}] - ${label}`);
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

export { Poll, Logger };
