if (iOS()) {
    document.body.classList.add("iOS");
}

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

/** @type {Object.<string, UKDiscoveredDevice>} */
let discoveredDevices = {};
function requestDiscoveredDevices() {
    browser.runtime.sendMessage({ type: "requestDiscoveredDevices" }).then((response) => {
        console.log("requestDiscoveredDevices response: ", response);
        setDiscoveredDevices(response.discoveredDevices);
    });
}
requestDiscoveredDevices();

const discoveredDevicesPoll = new Poll(() => {
    requestDiscoveredDevices();
}, 200);

/** @type {HTMLTemplateElement} */
const discoveredDeviceTemplate = document.getElementById("discoveredDeviceTemplate");
const discoveredDevicesContainer = document.getElementById("discoveredDevices");
/**
 *
 * @param {[UKDiscoveredDevice]} newDiscoveredDevices
 */
function setDiscoveredDevices(newDiscoveredDevices) {
    for (const id in discoveredDevices) {
        discoveredDevices[id].shouldRemove = true;
    }

    newDiscoveredDevices.forEach((discoveredDevice) => {
        const { id, name, deviceType, ipAddress, rssi, timestampDifference, connectionStatus, connectionType } =
            discoveredDevice;

        if (discoveredDevices[id]) {
            delete discoveredDevices[id].shouldRemove;
            Object.assign(discoveredDevices[id], discoveredDevice);
        } else {
            let expectedConnectionStatus = connectionStatus;
            const connectionStatusPoll = new Poll(() => {
                browser.runtime.sendMessage({ type: "requestConnectionStatus", id }).then((response) => {
                    console.log("isConnected response: ", response);
                });
            }, 500);
            const onConnectionStatusUpdate = (response) => {
                console.log("connectionStatus response: ", response);
                discoveredDevice.connectionStatus = response.connectionStatus;
                container.dataset.connectionStatus = response.connectionStatus;

                discoveredDevice.connectionType = response.connectionType;
                container.dataset.connectionType = response.connectionType;

                if (response.connectionStatus == expectedConnectionStatus) {
                    console.log("connection updated!");
                    connectionStatusPoll.stop();
                }
            };
            const container = discoveredDeviceTemplate.content.cloneNode(true).querySelector(".discoveredDevice");
            container.querySelector(".connectBle").addEventListener("click", () => {
                browser.runtime.sendMessage({ type: "connect", id, connectionType: "bluetooth" }).then((response) => {
                    console.log("connect response: ", response);
                    expectedConnectionStatus = "connected";
                    connectionStatusPoll.start();
                });
            });
            container.querySelector(".connectUdp").addEventListener("click", () => {
                browser.runtime.sendMessage({ type: "connect", id, connectionType: "udp" }).then((response) => {
                    console.log("connect response: ", response);
                    expectedConnectionStatus = "connected";
                    connectionStatusPoll.start();
                });
            });
            container.querySelector(".disconnect").addEventListener("click", () => {
                browser.runtime.sendMessage({ type: "disconnect", id }).then((response) => {
                    console.log("disconnect response: ", response);
                    expectedConnectionStatus = "not connected";
                    connectionStatusPoll.start();
                });
            });
            discoveredDevice.container = container;
            discoveredDevices[id] = discoveredDevice;
            discoveredDevices[id].connectionStatusPoll = connectionStatusPoll;
            discoveredDevices[id].onConnectionStatusUpdate = onConnectionStatusUpdate;
            discoveredDevicesContainer.appendChild(container);
        }

        const { container } = discoveredDevices[id];
        container.dataset.deviceType = deviceType;
        container.dataset.connectionStatus = connectionStatus;
        if (connectionType) {
            container.dataset.connectionType = connectionType;
        }
        container.querySelector(".name").innerText = name;
        container.querySelector(".deviceType").innerText = deviceType;
        container.querySelector(".rssi").innerText = rssi;
        if (timestampDifference) {
            container.querySelector(".timestampDifference").innerText = timestampDifference.toFixed(3);
        }
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

function setDiscoveredDeviceConnectionStatus(response) {
    const discoveredDevice = discoveredDevices[response.id];
    discoveredDevice.onConnectionStatusUpdate(response);
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
        case "connectionStatus":
            setDiscoveredDeviceConnectionStatus(message);
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
