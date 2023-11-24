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
function toggleScan() {
    sendMessage({ type: "toggleScan" }, (response) => {
        console.log("Received toggleScan response:", response);
        isScanning = response.isScanning;
        isScanningTimestamp = response.timestamp;
        browser.runtime.sendMessage({ type: "isScanning", isScanning });
    });
}
function stopScan() {
    sendMessage({ type: "stopScan" }, (response) => {
        console.log("Received toggleScan response:", response);
        isScanning = response.isScanning;
        isScanningTimestamp = response.timestamp;
        browser.runtime.sendMessage({ type: "isScanning", isScanning });
    });
}
function requestIsScanning() {
    sendMessage(
        {
            type: "requestIsScanning",
            timestamp: isScanningTimestamp,
        },
        (response) => {
            console.log("Received requestIsScanning response:", response);
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
function requestDiscoveredDevices() {
    sendMessage(
        {
            type: "requestDiscoveredDevices",
            timestamp: discoveredDevicesTimestamp,
        },
        (response) => {
            console.log("Received requestDiscoveredDevices response:", response);
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
function requestIsConnected({ id }) {
    sendMessage({ type: "requestIsConnected", id }, (response) => {
        console.log("Received isConnected response:", response);
        const discoveredDevice = getDiscoveredDeviceById(id);
        const newIsConnected = response.isConnected;
        discoveredDevice.isConnected = newIsConnected;
        browser.runtime.sendMessage({ type: "isConnected", id, isConnected: newIsConnected });
    });
}

// background.js <- popup.js/content.js
browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    console.log("Received message: ", message);

    const { type } = message;

    switch (type) {
        case "isScanning":
            requestIsScanning();
            sendResponse({ isScanning });
            break;
        case "toggleScan":
            toggleScan();
            sendResponse({ isScanning });
            break;
        case "stopScan":
            stopScan();
            sendResponse({ isScanning });
            break;
        case "requestDiscoveredDevices":
            requestDiscoveredDevices();
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
        case "requestIsConnected":
            requestIsConnected(message);
            sendResponse(message);
            break;
        default:
            console.log("uncaught message type", message.type);
            break;
    }
});
