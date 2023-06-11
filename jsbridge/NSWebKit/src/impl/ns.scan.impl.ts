import core from "./ns.core.impl";
import {NSWebKit} from "../plugins/ns"
import {
    ParamScanCode
} from "../plugins/ns.scan";

export const scan:NSWebKit = <NSWebKit>{
    async scanCode(param: ParamScanCode) {
        return await core.cordovaExec("NSScanPlugin", "scanCode", [param]);
    },
}