const logger = {
    isEnabled: true,
    /**
     *
     * @param {string} label
     * @param  {...any} rest
     */
    log(label, ...rest) {
        if (this.isEnabled) {
            console.groupCollapsed(`[content.js] - ${label}`);
            if (rest.length > 0) {
                console.log(...rest);
            }
            console.trace(); // hidden in collapsed group
            console.groupEnd();
        }
    },
};

window.addEventListener("ukatonkit-sendBackgroundMessage", async (event) => {
    const { id, message } = event.detail;
    const response = await browser.runtime.sendMessage(message);
    window.dispatchEvent(new CustomEvent(`ukatonkit-sendBackgroundMessage-${id}`, { detail: response }));
});

browser.runtime.onMessage.addListener((message) => {
    window.dispatchEvent(new CustomEvent("ukatonkit-backgroundListener", { detail: message }));
});
