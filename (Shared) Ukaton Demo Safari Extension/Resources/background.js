// background.js -> SafariWebExtesionHandler.swift
function sendMessage(message, callback) {
    browser.runtime.sendNativeMessage("application.id", message, (response) => {
        if (response) {
            callback(response);
        }
    });
}

var isScanning = false;
var isScanningTimestamp = 0;
function setScan({ newValue }) {
    sendMessage({ type: "setScan", newValue }, (response) => {
        console.log("Received setScan response:", response);
        isScanning = response.isScanning;
        isScanningTimestamp = response.timestamp;
        browser.runtime.sendMessage({ type: "isScanning", isScanning });
    });
}
function checkIsScanning() {
    sendMessage(
        {
            type: "isScanning",
            timestamp: isScanningTimestamp,
        },
        (response) => {
            console.log("Received checkIsScanning response:", response);
            isScanning = response.isScanning;
            isScanningTimestamp = response.timestamp;
            browser.runtime.sendMessage({ type: "isScanning", isScanning });
        }
    );
}

var discoveredDevices = [];
function getDiscoveredDeviceById(id) {
    return discoveredDevices.find((discoveredDevice) => discoveredDevice.id == id);
}
var discoveredDevicesTimestamp = 0;
function checkDiscoveredDevices() {
    sendMessage(
        {
            type: "discoveredDevices",
            timestamp: discoveredDevicesTimestamp,
        },
        (response) => {
            console.log("Received discoveredDevices response:", response);
            discoveredDevices = response.discoveredDevices;
            discoveredDevicesTimestamp = response.timestamp;
            browser.runtime.sendMessage({ type: "discoveredDevices", discoveredDevices });
        }
    );
}

function connect({ id, connectionType }) {
    sendMessage({ type: "connect", id, connectionType }, (response) => {
        console.log("Received connect response:", response);
    });
}
function disconnect({ id }) {
    sendMessage({ type: "disconnect", id }, (response) => {
        console.log("Received disconnect response:", response);
    });
}
function connectionStatus({ id }) {
    sendMessage({ type: "connectionStatus", id }, (response) => {
        console.log("Received connectionStatus response:", response);
        const discoveredDevice = getDiscoveredDeviceById(id);
        const newConnectionStatus = response.connectionStatus;
        const newConnectionType = response.connectionType;
        discoveredDevice.connectionStatus = newConnectionStatus;
        discoveredDevice.connectionType = newConnectionType;
        browser.runtime.sendMessage({
            type: "connectionStatus",
            id,
            connectionStatus: newConnectionStatus,
            connectionType: newConnectionType,
        });
    });
}

// background.js <- popup.js/content.js
browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    console.log("Received message: ", message);

    const { type } = message;

    switch (type) {
        case "isScanning":
            checkIsScanning();
            sendResponse({ isScanning });
            break;
        case "setScan":
            setScan(message);
            sendResponse({ isScanning });
            break;
        case "discoveredDevices":
            checkDiscoveredDevices();
            sendResponse({ discoveredDevices });
            break;

        case "connect":
            connect(message);
            sendResponse(message);
            break;
        case "disconnect":
            disconnect(message);
            sendResponse(message);
            break;

        case "connectionStatus":
            connectionStatus(message);
            sendResponse(message);
            break;

        default:
            console.log("uncaught message type", message.type);
            break;
    }
});
