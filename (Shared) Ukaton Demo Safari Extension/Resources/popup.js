// SCANNING
var isScanning = false;
var expectedIsScanning = isScanning;
function setIsScanning(newIsScanning) {
    if (newIsScanning == expectedIsScanning) {
        isScanningPoll.stop();
        console.log("set isScannng", newIsScanning);
        isScanning = newIsScanning;
        toggleScanButton.innerText = isScanning ? "stop scanning" : "scan for devices";

        if (isScanning) {
            discoveredDevicesPoll.start();
        } else {
            discoveredDevicesPoll.stop();
        }
    } else {
        isScanningPoll.start();
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

const isScanningPoll = new Poll(() => {
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
 * @property {boolean} isConnected
 * @property {number} rssi
 * @property {HTMLElement|undefined} container
 * @property {string|undefined} ipAddress
 * @property {number} timestampDifference
 */
/** @type {Object.<string, DiscoveredDevice>} */
var discoveredDevices = {};

const discoveredDevicesPoll = new Poll(() => {
    browser.runtime.sendMessage({ type: "requestDiscoveredDevices" }).then((response) => {
        console.log("requestDiscoveredDevices response: ", response);
        setDiscoveredDevices(response.discoveredDevices);
    });
}, 200);

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
        const { id, name, deviceType, ipAddress, rssi, timestampDifference, isConnected } = discoveredDevice;

        if (discoveredDevices[id]) {
            delete discoveredDevices[id].shouldRemove;
            Object.assign(discoveredDevices[id], discoveredDevice);
        } else {
            const container = discoveredDeviceTemplate.content.cloneNode(true).querySelector(".discoveredDevice");
            // add listeners
            discoveredDevice.container = container;
            discoveredDevices[id] = discoveredDevice;
            discoveredDevicesContainer.appendChild(container);
        }

        const { container } = discoveredDevices[id];
        container.dataset.deviceType = deviceType;
        container.dataset.isConnected = isConnected;
        container.querySelector(".name").innerText = name;
        container.querySelector(".deviceType").innerText = deviceType;
        container.querySelector(".rssi").innerText = rssi;
        container.querySelector(".timestampDifference").innerText = timestampDifference.toFixed(3);
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

window.addEventListener("unload", () => {
    if (isScanning) {
        browser.runtime.sendMessage({ type: "stopScan" }).then((response) => {
            console.log("stopScan response: ", response);
            setIsScanning(response.isScanning);
        });
    }
});
