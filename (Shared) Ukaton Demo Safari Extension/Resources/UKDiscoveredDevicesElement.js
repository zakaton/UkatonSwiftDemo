import { LitElement, html, css, repeat } from "./lit-all.min.js";
import UKDiscoveredDevicesController from "./UKDiscoveredDevicesController.js";
import UKDiscoveredDeviceElement from "./UKDiscoveredDeviceElement.js";
import { bluetoothManager } from "./UkatonKit.js";

export default class UKDiscoveredDevicesElement extends LitElement {
    discoveredDevicesController = new UKDiscoveredDevicesController(this);

    static styles = css`
        #discoveredDevices {
            display: flex;
            flex-direction: column;
            gap: 1.5em;
            justify-content: center;
        }
    `;

    render() {
        if (Object.keys(bluetoothManager.discoveredDevices).length > 0) {
            return html`
                <div id="discoveredDevices">
                    ${repeat(
                        Object.values(bluetoothManager.discoveredDevices),
                        (discoveredDevice) => discoveredDevice.id,
                        (discoveredDevice, index) =>
                            html`<uk-discovered-device .discoveredDevice=${discoveredDevice}></uk-discovered-device>`
                    )}
                </ul>
            `;
        } else {
            return html`<div>no devices found</div>`;
        }
    }
}
customElements.define("uk-discovered-devices", UKDiscoveredDevicesElement);
