import { LitElement, html } from "./lit-all.min.js";
import { UKDiscoveredDevicesElement } from "./discovered-devices-component.js";
import { UKScanButtonElement } from "./scan-button-component.js";

export class UKPopupElement extends LitElement {
    render() {
        return html` <uk-scan-button></uk-scan-button> <uk-discovered-devices></uk-discovered-devices> `;
    }
}
customElements.define("uk-popup", UKPopupElement);
