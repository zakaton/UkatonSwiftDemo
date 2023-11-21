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
