import UKDiscoveredDevice from "./UKDiscoveredDevice.js";
import { LitElement, html, css, choose } from "./lit-all.min.js";
import { is_iOS } from "./utils.js";
import { DiscoveredDeviceController } from "./discovered-device-controller.js";
import { bluetoothManager } from "./UkatonKit.js";
import { ScanController } from "./scan-controller.js";
import { wifiIcon, signalIcon, clockIcon } from "./icons.js";

export class UKDiscoveredDeviceElement extends LitElement {
    /** @type {UKDiscoveredDevice} */
    discoveredDevice;
    /** @type {DiscoveredDeviceController} */
    discoveredDeviceController;

    scanController = new ScanController(this);

    static styles = css`
        .discoveredDevice {
            display: flex;
            flex-direction: column;
            gap: 0.2em;
        }

        .header {
            display: flex;
            flex-direction: row;
            justify-content: center;
            align-items: baseline;
            gap: 0.8em;
        }
        .name {
            font-size: x-large;
        }

        .icon {
            display: inline-block;
        }
        .mirror {
            transform: scale(-1, 1);
        }

        button {
            font-size: large;
        }

        @keyframes pulsateAnimation {
            0% {
                scale: 1;
            }
            100% {
                scale: 0.95;
            }
        }
        .pulsating {
            opacity: 1;
            animation: pulsateAnimation 0.6s infinite;
            animation-timing-function: ease-in-out;
            animation-direction: alternate;
        }

        .connection {
            display: flex;
            flex-direction: row;
            justify-content: center;
            gap: 0.5em;
            align-items: center;
        }

        .status {
            display: flex;
            flex-direction: row;
            justify-content: center;
            gap: 0.7em;
        }

        .status > *:not([hidden]) {
            display: flex;
            flex-direction: row;
            align-items: center;
            gap: 0.3em;
        }

        svg {
            height: 1em;
        }
    `;

    connectedCallback() {
        super.connectedCallback();
        this.discoveredDeviceController = new DiscoveredDeviceController(this, this.discoveredDevice);
    }

    headerTemplate() {
        return html`
            <div class="header">
                <b><span class="name">${this.discoveredDevice.name}</span></b>

                <span class="deviceType"
                    ><div class="icon ${this.discoveredDevice.deviceType == "left insole" ? "mirror" : ""}">
                        ${this.icon}
                    </div>
                    ${this.discoveredDevice.deviceType}</span
                >
            </div>
        `;
    }
    get icon() {
        switch (this.discoveredDevice.deviceType) {
            case "left insole":
            case "right insole":
                return "👟";
            case "motion module":
                return "📦";
        }
    }

    notConnectedTemplate() {
        return html`<div>connect via:</div>
            <button @click=${() => this.discoveredDevice.connect("bluetooth")}>bluetooth</button>
            <button @click=${() => this.discoveredDevice.connect("udp")} ?hidden=${is_iOS}>udp</button>`;
    }
    connectingTemplate() {
        return html`
            <button class="pulsating" @click=${() => this.discoveredDevice.disconnect()}>
                connecting via ${this.discoveredDevice.connectionType}...
            </button>
        `;
    }
    connectedTemplate() {
        return html`
            <div>connected via ${this.discoveredDevice.connectionType}</div>
            <button @click=${() => this.discoveredDevice.disconnect()}>disconnect</button>
        `;
    }
    disconnectingTemplate() {
        return html`<div class="pulsating">disconnecting...</div> `;
    }

    connectionTemplate() {
        return html`
            <div class="connection">
                ${choose(
                    this.discoveredDevice.connectionStatus,
                    [
                        ["not connected", () => this.notConnectedTemplate()],
                        ["connecting", () => this.connectingTemplate()],
                        ["connected", () => this.connectedTemplate()],
                        ["disconnecting", () => this.disconnectingTemplate()],
                    ],
                    () => html`<div>error</div>`
                )}
            </div>
        `;
    }

    get showScanningStatus() {
        return bluetoothManager.isScanning && this.discoveredDevice.connectionStatus == "not connected";
    }

    statusTemplate() {
        return html`
            <div class="status">
                <div class="rssi" ?hidden=${!this.showScanningStatus || !this.discoveredDevice.rssi}>
                    ${signalIcon()} <span>${this.discoveredDevice.rssi}</span>
                </div>

                <div
                    class="timestampDifference"
                    ?hidden=${!this.showScanningStatus || !this.discoveredDevice.timestampDifference}
                >
                    ${clockIcon()} <span>${this.discoveredDevice.timestampDifference?.toFixed(3)}</span>
                </div>

                <div class="ipAddress" ?hidden=${!this.discoveredDevice.isConnectedToWifi}>
                    ${wifiIcon()} <span>${this.discoveredDevice.ipAddress}</span>
                </div>
            </div>
        `;
    }

    render() {
        return html`<div class="discoveredDevice">
            ${this.headerTemplate()} ${this.connectionTemplate()} ${this.statusTemplate()}
        </div>`;
    }
}
customElements.define("uk-discovered-device", UKDiscoveredDeviceElement);
