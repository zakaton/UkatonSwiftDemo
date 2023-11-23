var isScanning = false;
function toggleScan(sender) {
    browser.runtime.sendNativeMessage(
        "application.id",
        { type: "toggleScan" },
        function (response) {
            console.log("Received sendNativeMessage response:", response);
            isScanning = response.isScanning;
            browser.runtime.sendMessage({ type: "isScanning", isScanning });
        }
    );
}

var discoveredDevices = [];

// content.js -> background.js
browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    console.log("Received message: ", message);

    switch (message.type) {
        case "isScanning":
            sendResponse({ isScanning });
            break;
        case "toggleScan":
            toggleScan(sender);
            sendResponse({ isScanning });
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

// SafariWebExtesionHandler.swift -> background.js
let port = browser.runtime.connectNative("application.id");
port.onMessage.addListener(function ({ name: type, userInfo: message }) {
    console.log("Received native port message:", type, message);

    switch (type) {
        case "isScanning":
            isScanning = message.isScanning;
            browser.runtime.sendMessage({ type: "isScanning", isScanning });
            break;
        case "discoveredDevices":
            discoveredDevices = message.discoveredDevices;
            browser.runtime.sendMessage({
                type: "discoveredDevices",
                discoveredDevices,
            });
            break;
        default:
            console.log("uncaught message name", type);
            break;
    }
});
