import { bluetoothManager } from "./UkatonKit.js";
import { ScanController } from "./scan-controller.js";
import { LitElement, html, css } from "./lit-all.min.js";
import { UKDiscoveredDevicesElement } from "./discovered-devices-component.js";

export class UKPopupElement extends LitElement {
    scanController = new ScanController(this);

    static properties = {};
    static styles = css`
        #toggleScanButton {
            font-size: larger;
        }
    `;

    constructor() {
        super();
    }

    toggleScanButtonTemplate() {
        return html`
            <button @click=${() => bluetoothManager.toggleScan()} id="toggleScanButton">
                ${bluetoothManager.isScanning ? "stop scanning" : "scan"}
            </button>
        `;
    }

    render() {
        return html` ${this.toggleScanButtonTemplate()} <uk-discovered-devices /> `;
    }
}
customElements.define("uk-popup", UKPopupElement);
