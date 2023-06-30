import core from "./ns.core.impl";
import {NSWebKit} from "../plugins/ns"
import {ParamChooseLocation} from "../plugins/ns.location";

export const location:NSWebKit = <NSWebKit>{
    async getLocationInfo() {
        return await core.cordovaExec("NSLocationPlugin", "getLocationInfo");
    },

    async chooseLocation(param: ParamChooseLocation) {
        return await core.cordovaExec("NSChooseLocationPlugin", "chooseLocation", [param]);
    }
}