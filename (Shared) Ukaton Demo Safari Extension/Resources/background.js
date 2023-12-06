const logger = {
    isEnabled: false,
    log(label, ...rest) {
        if (this.isEnabled) {
            console.groupCollapsed(label);
            if (rest.length > 0) {
                console.log(...rest);
            }
            console.trace();
            console.groupEnd();
        }
    },
};

// background.js -> SafariWebExtesionHandler.swift
function sendMessage(message, callback) {
    browser.runtime.sendNativeMessage("application.id", message, (response) => {
        if (response) {
            callback(response);
        }
    });
}

// background.js -> content.js/popup.js
async function sendMessageToWebpage(message) {
    browser.runtime.sendMessage(message);
    const tab = await browser.tabs.getCurrent();
    browser.tabs.sendMessage(tab.id, message);
}

var isScanning = false;
var isScanningTimestamp = 0;
function setScan({ newValue }) {
    sendMessage({ type: "setScan", newValue }, (response) => {
        onIsScanningResponse(response);
    });
}
function checkIsScanning() {
    sendMessage(
        {
            type: "isScanning",
            timestamp: isScanningTimestamp,
        },
        (response) => {
            onIsScanningResponse(response);
        }
    );
}

function onIsScanningResponse(response) {
    logger.log(`Received checkIsScanning response: ${response.isScanning}`, response);
    isScanning = response.isScanning;
    isScanningTimestamp = response.timestamp;
    sendMessageToWebpage({ type: "isScanning", isScanning });
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
            logger.log(`Received ${response.discoveredDevices.length} discoveredDevices`, response);
            discoveredDevices = response.discoveredDevices;
            discoveredDevicesTimestamp = response.timestamp;
            sendMessageToWebpage({ type: "discoveredDevices", discoveredDevices });
        }
    );
}

function connect({ id, connectionType }) {
    sendMessage({ type: "connect", id, connectionType }, (response) => {
        logger.log(`Received connect response`, response);
    });
}
function disconnect({ id }) {
    sendMessage({ type: "disconnect", id }, (response) => {
        logger.log(`Received disconnect response`, response);
    });
}
function checkConnectionStatus({ id }) {
    sendMessage({ type: "connectionStatus", id }, (response) => {
        logger.log(
            `Received connectionStatus response: ${response.connectionStatus} via ${response.connectionType}`,
            response
        );
        const discoveredDevice = getDiscoveredDeviceById(id);
        const newConnectionStatus = response.connectionStatus;
        const newConnectionType = response.connectionType;
        discoveredDevice.connectionStatus = newConnectionStatus;
        discoveredDevice.connectionType = newConnectionType;
        sendMessageToWebpage({
            type: "connectionStatus",
            id,
            connectionStatus: newConnectionStatus,
            connectionType: newConnectionType,
        });
    });
}

function getSensorDataConfigurations({ id }) {
    const discoveredDevice = getDiscoveredDeviceById(id);
    sendMessage(
        { type: "getSensorDataConfigurations", id, timestamp: discoveredDevice.sensorDataConfigurationsTimestamp },
        (response) => {
            logger.log(
                `Received getSensorDataConfigurations response: ${JSON.stringify(response.sensorDataConfigurations)}`,
                response
            );
            onSensorDataConfigurationsResponse(id, response);
        }
    );
}
function setSensorDataConfigurations({ id, sensorDataConfigurations }) {
    sendMessage({ type: "setSensorDataConfigurations", id, sensorDataConfigurations }, (response) => {
        logger.log(
            `Received setSensorDataConfigurations response: ${JSON.stringify(response.sensorDataConfigurations)}`,
            response
        );
        //onSensorDataConfigurationsResponse(id, response);
    });
}

function clearSensorDataConfigurations({ id }) {
    sendMessage({ type: "clearSensorDataConfigurations", id }, (response) => {
        logger.log(`Received clearSensorDataConfigurations response: ${JSON.stringify(response)}`, response);
    });
}

function onSensorDataConfigurationsResponse(id, response) {
    const discoveredDevice = getDiscoveredDeviceById(id);
    const newSensorDataConfigurations = response.sensorDataConfigurations;
    const sensorDataConfigurationsTimestamp = response.timestamp;

    discoveredDevice.sensorDataConfigurations = newSensorDataConfigurations;
    discoveredDevice.sensorDataConfigurationsTimestamp = sensorDataConfigurationsTimestamp;
    sendMessageToWebpage({
        type: "sensorDataConfigurations",
        id,
        sensorDataConfigurations: newSensorDataConfigurations,
    });
}

function checkSensorData({ id, timestamp }) {
    sendMessage({ type: "sensorData", id, timestamp }, (response) => {
        const { sensorData, timestamp } = response;
        logger.log(`Received sensorData response: ${JSON.stringify(sensorData)}`, response);
        sendMessageToWebpage({
            type: "sensorData",
            id,
            sensorData,
            timestamp,
        });
    });
}

function vibrate({ id, vibrationType, vibration }) {
    sendMessage({ type: "vibrate", id, vibrationType, vibration }, (response) => {
        logger.log(`Received vibration response`, response);
    });
}

function sendMessageToApp(message) {
    logger.log(`sending ${message.type} message`, message);
    sendMessage(message, (response) => {
        logger.log(`Received ${message.type} response`, response);
        response.type = response.type || message.type;
        sendMessageToWebpage(response);
    });
}

// background.js <- popup.js/content.js
browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    logger.log(`Received message of type "${message.type}"`, message, sender);

    const { type } = message;

    let response = Object.assign({}, message);

    switch (type) {
        case "isScanning":
            checkIsScanning();
            response = { isScanning };
            break;
        case "setScan":
            setScan(message);
            response = { isScanning };
            break;
        case "discoveredDevices":
            checkDiscoveredDevices();
            response = { discoveredDevices };
            break;

        case "connect":
            connect(message);
            break;
        case "disconnect":
            disconnect(message);
            break;

        case "connectionStatus":
            checkConnectionStatus(message);
            break;

        case "getSensorDataConfigurations":
            getSensorDataConfigurations(message);
            break;
        case "setSensorDataConfigurations":
            setSensorDataConfigurations(message);
            break;
        case "clearSensorDataConfigurations":
            clearSensorDataConfigurations(message);
            break;

        case "sensorData":
            checkSensorData(message);
            break;

        case "vibrate":
            vibrate(message);
            break;

        case "isHeadphoneMotionAvailable":
            sendMessageToApp({ type });
            break;
        case "isHeadphoneMotionActive":
            sendMessageToApp({ type });
            break;
        case "startHeadphoneMotionUpdates":
            sendMessageToApp({ type });
            break;
        case "stopHeadphoneMotionUpdates":
            sendMessageToApp({ type });
            break;
        case "headphoneMotionData":
            sendMessageToApp(message);
            break;

        default:
            logger.log(`uncaught message type "${message.type}"`);
            break;
    }

    sendResponse(response);
});
