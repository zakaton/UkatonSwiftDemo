import UKDiscoveredDevice from "./UKDiscoveredDevice.js";
import { LitElement, html, css } from "./lit-all.min.js";

export class UKDiscoveredDeviceElement extends LitElement {
    static properties = {};
    static styles = css`
        .discoveredDevice {
        }
    `;

    /** @type {UKDiscoveredDevice} */
    discoveredDevice;

    constructor() {
        super();
    }

    render() {
        return html`<div class="discoveredDevice">${this.discoveredDevice.name}</div>`;
    }
}
customElements.define("uk-discovered-device", UKDiscoveredDeviceElement);
