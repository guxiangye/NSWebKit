
const TAG = "com.nswebkit.ts"
console.log(TAG, "start")

import {NSWebKit} from "./plugins/ns";
import {jsPrivateObj} from "./impl/ns.core.impl"
import {basic} from "./impl/ns.basic.impl"
import {customCamera} from "./impl/ns.customCamera.impl"
import {scan} from "./impl/ns.scan.impl"
import {location} from "./impl/ns.location.impl"
import {share} from "./impl/ns.share.impl"

const ns: NSWebKit = <NSWebKit>{
    ...jsPrivateObj,
    ...basic,
    ...customCamera,
    ...scan,
    ...location,
    ...share,
}
function spIsReady() {
    const readyEvent = new Event("NSReady");
    document.dispatchEvent(readyEvent);
}
if (!window.ns) {
    window.ns = ns;
    spIsReady();
}