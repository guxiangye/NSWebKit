import core from "./ns.core.impl";
import {NSWebKit} from "../plugins/ns"

export const location:NSWebKit = <NSWebKit>{
    async getLocationInfo() {
        return await core.cordovaExec("NSLocationPlugin", "getLocationInfo");
    }
}