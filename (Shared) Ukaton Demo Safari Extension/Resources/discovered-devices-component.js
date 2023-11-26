import { DiscoveredDevicesController } from "./discovered-devices-controller.js";
import { LitElement, html, css, repeat } from "./lit-all.min.js";
import { UKDiscoveredDeviceElement } from "./discovered-device-component.js";
import { bluetoothManager } from "./UkatonKit.js";

export class UKDiscoveredDevicesElement extends LitElement {
    discoveredDevicesController = new DiscoveredDevicesController(this);

    static styles = css`
        #discoveredDevices {
            display: flex;
            flex-direction: column;
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
