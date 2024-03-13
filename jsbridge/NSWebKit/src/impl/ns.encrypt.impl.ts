import core from "./ns.core.impl";
import {NSWebKit} from "../plugins/ns";

export const encrypt:NSWebKit = <NSWebKit>{
    async encryptAndCalculateMac(param: any) {
        return await core.cordovaExec("SPEncryptPlugin", "encryptAndCalculateMac", [param]);
    }
}