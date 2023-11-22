const responseDiv = document.getElementById("response")

var isScanning = false;
function setIsScanning(newIsScanning) {
    console.log("set isScannng", newIsScanning)
    isScanning = newIsScanning
    toggleScanButton.innerText = isScanning? "stop scan":"scan"
}

const toggleScanButton = document.getElementById("toggleScan")
toggleScanButton.addEventListener("click", () => {
    browser.runtime.sendMessage({ type: "toggleScan" }).then((response) => {
        console.log("toggleScan response: ", response);
        setIsScanning(response.isScanning)
    });
})

browser.runtime.sendMessage({ type: "isScanning" }).then((response) => {
    console.log("isScanning response: ", response);
    setIsScanning(response.isScanning)
});

browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    console.log("received request", request)
    
    switch (request.type) {
        case "isScanning":
            setIsScanning(request.isScanning)
            break;
        default:
            console.log("uncaught type", request.type)
    }
})
