import { html, render } from "./lit-core.min.js";
import { bluetoothManager } from "./UkatonKit.js";

const name = "world";
const sayHi = html`<h1>Hello ${name}</h1>`;
render(sayHi, document.body);

console.log(bluetoothManager);

console.log("FUC");
