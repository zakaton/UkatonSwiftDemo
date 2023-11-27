import { LitElement, html } from "./lit-all.min.js";
import UKDiscoveredDevicesElement from "./UKDiscoveredDevicesElement.js";
import UKScanButtonElement from "./UKScanButtonElement.js";

export class UKPopupElement extends LitElement {
    render() {
        return html`
            <uk-scan-button></uk-scan-button>
            <hr />
            <uk-discovered-devices></uk-discovered-devices>
        `;
    }
}
customElements.define("uk-popup", UKPopupElement);
