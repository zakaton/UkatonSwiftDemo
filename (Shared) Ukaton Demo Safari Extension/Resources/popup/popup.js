import { html, render } from "./lit-core.min.js";
import { UKBluetoothManager } from "./UkatonKit.js";

const name = "world";
const sayHi = html`<h1>Hello ${name}</h1>`;
render(sayHi, document.body);

console.log(UKBluetoothManager);

console.log("FUC")
