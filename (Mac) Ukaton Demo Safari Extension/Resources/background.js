var isScanning = false;
function toggleScan() {
    isScanning = !isScanning
}

browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    console.log("Received request: ", request);
    
    switch (request.type) {
        case "isScanning":
            sendResponse({ isScanning });
            break;
        case "toggleScan":
            toggleScan();
            sendResponse({ isScanning });
            break;
        default:
            console.log("uncaught request type", request.type);
            break;
    }

    if (request.greeting === "hello")
        sendResponse({ farewell: "goodbye" });
});

browser.runtime.sendNativeMessage("application.id", {message: "Hello from background page"}, function(response) {
    console.log("Received sendNativeMessage response:");
    console.log(response);
});
