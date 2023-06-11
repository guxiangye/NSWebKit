import core from "./ns.core.impl";
import {NSWebKit} from "../plugins/ns"
import {
    ParamShareToWX,
    ParamOpenWXMiniProgram,
    ParamShareToWXMiniProgram
} from "../plugins/ns.share";

export const share:NSWebKit = <NSWebKit>{
    async sendWXAuthRequest() {
        return await core.cordovaExec("NSSharePlugin", "sendWXAuthRequest");
    },

    async shareToWX(param: ParamShareToWX) {
        return await core.cordovaExec("NSSharePlugin", "shareToWX", [param]);
    },

    async launchWXMiniProgram(param: ParamOpenWXMiniProgram) {
        return await core.cordovaExec("NSSharePlugin", "launchWXMiniProgram", [param]);
    },

    async shareToWXMiniProgram(param: ParamShareToWXMiniProgram) {
        return await core.cordovaExec("NSSharePlugin", "shareToWXMiniProgram", [param]);
    }
}