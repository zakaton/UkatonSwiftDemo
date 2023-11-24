class Poll {
    /**
     *
     * @param {function():void} callback
     * @param {number} interval
     */
    constructor(callback, interval) {
        this.callback = callback;
        this.interval = interval;
        this.intervalId = null;
    }

    /** @type {number|null} */
    intervalId = null;

    get isRunning() {
        return this.intervalId != null;
    }

    start() {
        if (!this.isRunning) {
            this.intervalId = setInterval(() => this.callback(), this.interval);
        }
    }
    stop() {
        if (this.isRunning) {
            clearInterval(this.intervalId);
            this.intervalId = null;
        }
    }
}
