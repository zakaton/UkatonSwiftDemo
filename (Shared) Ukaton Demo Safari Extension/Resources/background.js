function sendMessage(message, callback) {
    browser.runtime.sendNativeMessage("application.id", message, callback);
}

var isScanning = false;
function toggleScan() {
    sendMessage({ type: "toggleScan" }, (response) => {
        console.log("Received toggleScan response:", response);
        isScanning = response.isScanning;
        browser.runtime.sendMessage({ type: "isScanning", isScanning });
    });
}
function requestIsScanning() {
    sendMessage({ type: "requestIsScanning" }, (response) => {
        console.log("Received requestIsScanning response:", response);
        isScanning = response.isScanning;
        browser.runtime.sendMessage({ type: "isScanning", isScanning });
    });
}

var discoveredDevices = [];
function requestDiscoveredDevices() {
    sendMessage({ type: "requestDiscoveredDevices" }, (response) => {
        console.log("Received requestDiscoveredDevices response:", response);
        discoveredDevices = response.discoveredDevices;
        browser.runtime.sendMessage({ type: "discoveredDevices", discoveredDevices });
    });
}

// background.js <- popup.js/content.js
browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    console.log("Received message: ", message);

    switch (message.type) {
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
browser.runtime.sendNativeMessage(
    "application.id",
    { message: "Hello from background page" },
    function (response) {
        console.log("Received sendNativeMessage response:");
        console.log(response);
    }
);
