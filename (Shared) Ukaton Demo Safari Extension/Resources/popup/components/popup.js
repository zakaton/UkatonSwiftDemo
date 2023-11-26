import { bluetoothManager } from "./UkatonKit.js";
import { LitElement, html, css } from "./lit-core.min.js";

export class UKPopupElement extends LitElement {
    static properties = {};
    static styles = css``;
    constructor() {
        super();
    }
    render() {
        return html`
            <h1>Hello world!</h1>
            <button>wow</button>
        `;
    }
}
customElements.define("uk-popup", UKPopupElement);
