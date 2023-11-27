import { bluetoothManager } from "./UkatonKit.js";
import UKScanController from "./UKScanController.js";
import { LitElement, html, css } from "./lit-all.min.js";

export default class UKScanButtonElement extends LitElement {
    scanController = new UKScanController(this);

    static styles = css`
        #toggleScanButton {
            font-size: larger;
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
            animation: pulsateAnimation 0.7s infinite;
            animation-timing-function: ease-in-out;
            animation-direction: alternate;
        }
    `;

    render() {
        return html`
            <button
                class="${bluetoothManager.isScanning ? "pulsating" : ""}"
                @click=${() => bluetoothManager.toggleScan()}
                id="toggleScanButton"
            >
                ${bluetoothManager.isScanning ? "scanning for devices..." : "scan for devices"}
            </button>
        `;
    }
}
customElements.define("uk-scan-button", UKScanButtonElement);
