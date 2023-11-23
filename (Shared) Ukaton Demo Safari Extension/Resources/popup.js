// SCANNING
var isScanning = false;
var expectedIsScanning = isScanning;
function setIsScanning(newIsScanning) {
    if (newIsScanning == expectedIsScanning) {
        pollForIsScanningUpdate.stop();
        console.log("set isScannng", newIsScanning);
        isScanning = newIsScanning;
        toggleScanButton.innerText = isScanning ? "stop scan" : "scan";

        if (isScanning) {
            pollDiscoveredDevicesUpdate.start();
        } else {
            pollDiscoveredDevicesUpdate.stop();
        }
    } else {
        pollForIsScanningUpdate.start();
    }
}

const toggleScanButton = document.getElementById("toggleScan");
toggleScanButton.addEventListener("click", () => {
    expectedIsScanning = !expectedIsScanning;
    browser.runtime.sendMessage({ type: "toggleScan" }).then((response) => {
        console.log("toggleScan response: ", response);
        setIsScanning(response.isScanning);
    });
});

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

const pollForIsScanningUpdate = new Poll(() => {
    browser.runtime.sendMessage({ type: "isScanning" }).then((response) => {
        console.log("toggleScan response: ", response);
        setIsScanning(response.isScanning);
    });
}, 100);

browser.runtime.sendMessage({ type: "isScanning" }).then((response) => {
    console.log("isScanning response: ", response);
    expectedIsScanning = response.isScanning;
    setIsScanning(response.isScanning);
});

// DISCOVERED DEVICES
/**
 * @typedef DiscoveredDevice
 * @type {object}
 * @property {string} id
 * @property {string} name
 * @property {number} deviceType
 * @property {number} rssi
 * @property {HTMLElement|undefined} container
 * @property {string|undefined} ipAddress
 */
/** @type {Object.<string, DiscoveredDevice>} */
var discoveredDevices = {};

const pollDiscoveredDevicesUpdate = new Poll(() => {
    browser.runtime.sendMessage({ type: "requestDiscoveredDevices" }).then((response) => {
        console.log("requestDiscoveredDevices response: ", response);
        setDiscoveredDevices(response.discoveredDevices);
    });
}, 100);

/** @type {HTMLTemplateElement} */
const discoveredDeviceTemplate = document.getElementById("discoveredDeviceTemplate");
const discoveredDevicesContainer = document.getElementById("discoveredDevices");
/**
 *
 * @param {[DiscoveredDevice]} newDiscoveredDevices
 */
function setDiscoveredDevices(newDiscoveredDevices) {
    for (const id in discoveredDevices) {
        discoveredDevices[id].shouldRemove = true;
    }

    newDiscoveredDevices.forEach((discoveredDevice) => {
        const { id, name, deviceType, ipAddress, rssi } = discoveredDevice;

        if (discoveredDevices[id]) {
            delete discoveredDevices[id].shouldRemove;
            Object.assign(discoveredDevices[id], discoveredDevice);
        } else {
            const container = discoveredDeviceTemplate.content
                .cloneNode(true)
                .querySelector(".discoveredDevice");
            // add listeners
            discoveredDevice.container = container;
            discoveredDevices[id] = discoveredDevice;
            discoveredDevicesContainer.appendChild(container);
        }

        // FILL - styling
        const { container } = discoveredDevices[id];
        console.log(container.querySelector(".name"));
        container.querySelector(".name").innerText = name;
        container.querySelector(".deviceType").innerText = deviceType;
        container.querySelector(".rssi").innerText = rssi;
        if (ipAddress) {
            container.querySelector(".ipAddress").innerText = ipAddress;
            container.querySelector(".ipAddress").classList.remove(".hidden");
            container.querySelector(".connectUdp").classList.remove(".hidden");
        } else {
            container.querySelector(".ipAddress").classList.add(".hidden");
            container.querySelector(".connectUdp").classList.add(".hidden");
        }
    });

    for (const id in discoveredDevices) {
        if (discoveredDevices[id].shouldRemove) {
            discoveredDevices[id].container.remove();
            delete discoveredDevices[id];
        }
    }

    console.log("discoveredDevices", discoveredDevices);
}

// popup.js <- background.js
browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    console.log("received message", message);

    switch (message.type) {
        case "isScanning":
            setIsScanning(message.isScanning);
            break;
        case "discoveredDevices":
            setDiscoveredDevices(message.discoveredDevices);
            break;
        default:
            console.log("uncaught type", message.type);
    }
});
