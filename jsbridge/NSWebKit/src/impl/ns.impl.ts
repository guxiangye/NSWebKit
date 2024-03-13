import {jsPrivateObj} from "./ns.core.impl"
import {basic} from "./ns.basic.impl"
import {customCamera} from "./ns.customCamera.impl"
import {scan} from "./ns.scan.impl"
import {location} from "./ns.location.impl"
import {share} from "./ns.share.impl"
import {encrypt} from "./ns.encrypt.impl"

const ns = {
    ...jsPrivateObj,
    ...basic,
    ...customCamera,
    ...scan,
    ...location,
    ...share,
    ...encrypt
}

function spIsReady() {
    const readyEvent = new Event("NSReady");
    document.dispatchEvent(readyEvent);
}
if (!window.ns) {
    window.ns = ns;
    spIsReady();
}

export default ns