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
        case "requestDiscoveredDevices":
            requestDiscoveredDevices();
            sendResponse({ discoveredDevices });
            break;
        default:
            console.log("uncaught message type", message.type);
            break;
    }

    if (message.greeting === "hello") sendResponse({ farewell: "goodbye" });
});

// background.js -> SafariWebExtesionHandler.swift
browser.runtime.sendNativeMessage("application.id", { message: "Hello from background page" }, function (response) {
    console.log("Received sendNativeMessage response:");
    console.log(response);
});
