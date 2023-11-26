import UKDiscoveredDevice from "./UKDiscoveredDevice.js";
import { LitElement, html, css, choose } from "./lit-all.min.js";
import { is_iOS } from "./utils.js";
import { DiscoveredDeviceController } from "./discovered-device-controller.js";

export class UKDiscoveredDeviceElement extends LitElement {
    /** @type {UKDiscoveredDevice} */
    discoveredDevice;
    /** @type {DiscoveredDeviceController} */
    discoveredDeviceController;

    static styles = css`
        .discoveredDevice {
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
                <span class="deviceType">${this.discoveredDevice.deviceType}</span>
            </div>
        `;
    }

    notConnectedTemplate() {
        return html`<div>connect via:</div>
            <button @click=${() => this.discoveredDevice.connect("bluetooth")}>bluetooth</button>
            <button @click=${() => this.discoveredDevice.connect("udp")} ?hidden=${is_iOS}>udp</button>`;
    }
    connectingTemplate() {
        return html`
            <button @click=${() => this.discoveredDevice.disconnect()}>
                connecting via ${this.discoveredDevice.connectionType}...
            </button>
        `;
    }
    connectedTemplate() {
        return html` <div>connected via ${this.discoveredDevice.connectionType}</div> `;
    }
    disconnectingTemplate() {
        return html`<div>disconnecting...</div> `;
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

    statusTemplate() {
        return html`
            <div class="status">
                <span class="rssi" ?hidden=${!this.discoveredDevice.rssi}>${this.discoveredDevice.rssi}</span>
                <span class="timestampDifference" ?hidden=${!this.discoveredDevice.timestampDifference}
                    >${this.discoveredDevice.timestampDifference.toFixed(3)}</span
                >
                <span class="ipAddress" ?hidden=${!this.discoveredDevice.isConnectedToWifi}
                    >${this.discoveredDevice.ipAddress}</span
                >
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
