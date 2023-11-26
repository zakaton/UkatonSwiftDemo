import { bluetoothManager } from "./UkatonKit.js";
import { ScanController } from "./scan-controller.js";
import { LitElement, html, css } from "./lit-all.min.js";

export class UKScanButtonElement extends LitElement {
    scanController = new ScanController(this);

    static styles = css`
        #toggleScanButton {
            font-size: larger;
        }
    `;

    render() {
        return html`
            <button @click=${() => bluetoothManager.toggleScan()} id="toggleScanButton">
                ${bluetoothManager.isScanning ? "stop scanning" : "scan for devices"}
            </button>
        `;
    }
}
customElements.define("uk-scan-button", UKScanButtonElement);
