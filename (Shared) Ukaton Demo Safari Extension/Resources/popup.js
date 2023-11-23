var isScanning = false;
function setIsScanning(newIsScanning) {
    console.log("set isScannng", newIsScanning);
    isScanning = newIsScanning;
    toggleScanButton.innerText = isScanning ? "stop scan" : "scan";
}

const toggleScanButton = document.getElementById("toggleScan");
toggleScanButton.addEventListener("click", () => {
    browser.runtime.sendMessage({ type: "toggleScan" }).then((response) => {
        console.log("toggleScan response: ", response);
        setIsScanning(response.isScanning);
    });
});

var discoveredDevices = {}; // {id: {rssi, name, deviceType, ipAddress}}
const discoveredDeviceTemplate = document.getElementById("discoveredDeviceTemplate");
const discoveredDevicesContainer = document.getElementById("discoveredDevices");
function setDiscoveredDevices(newDiscoveredDevices) {
    for (const id in discoveredDevices) {
        discoveredDevices[id].shouldRemove = true;
    }

    newDiscoveredDevices.forEach((discoveredDevice) => {
        const { id, name, deviceType, ipAddress, rssi } = discoveredDevice;

        if (discoveredDevices[id]) {
            delete discoveredDevices[id].shouldRemove;
            Object.assign(discoveredDevices[id], discoveredDevice);
        } else {
            const container = discoveredDeviceTemplate.content
                .cloneNode(true)
                .querySelector(".discoveredDevice");
            // add listeners
            discoveredDevice.container = container;
            discoveredDevices[id] = discoveredDevice;
            discoveredDevicesContainer.appendChild(container);
        }

        // FILL - styling
        const { container } = discoveredDevices[id];
        console.log(container.querySelector(".name"));
        container.querySelector(".name").innerText = name;
        container.querySelector(".deviceType").innerText = deviceType;
        container.querySelector(".rssi").innerText = rssi;
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

browser.runtime.sendMessage({ type: "isScanning" }).then((response) => {
    console.log("isScanning response: ", response);
    setIsScanning(response.isScanning);
});

browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    console.log("received message", message);

    switch (message.type) {
        case "isScanning":
            setIsScanning(message.isScanning);
            break;
        case "discoveredDevices":
            setDiscoveredDevices(message.discoveredDevices);
            break;
        default:
            console.log("uncaught type", message.type);
    }
});
