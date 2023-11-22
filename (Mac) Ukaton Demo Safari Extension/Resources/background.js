var isScanning = false;
function toggleScan(sender) {
    browser.runtime.sendNativeMessage("application.id", {type: "toggleScan"}, function(response) {
        console.log("Received sendNativeMessage response:", response);
        isScanning = response.isScanning
        browser.runtime.sendMessage({ type: "isScanning", isScanning })
    });
}

// content.js -> background.js
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    console.log("Received request: ", request);
    
    switch (request.type) {
        case "isScanning":
            sendResponse({ isScanning });
            break;
        case "toggleScan":
            toggleScan(sender)
            sendResponse({isScanning})
            break;
        default:
            console.log("uncaught request type", request.type);
            break;
    }

    if (request.greeting === "hello")
        sendResponse({ farewell: "goodbye" });
});

// background.js -> SafariWebExtesionHandler.swift
browser.runtime.sendNativeMessage("application.id", {message: "Hello from background page"}, function(response) {
    console.log("Received sendNativeMessage response:");
    console.log(response);
});

// SafariWebExtesionHandler.swift -> background.js
let port = browser.runtime.connectNative("application.id");
port.onMessage.addListener(function({name: type, userInfo: message}) {
    console.log("Received native port message:", type, message);
    
    switch (type) {
        case "isScanning":
            isScanning = message.isScanning
            browser.runtime.sendMessage({ type: "isScanning", isScanning })
            break;
        default:
            console.log("uncaught message name", message.name);
            break;
    }
});
