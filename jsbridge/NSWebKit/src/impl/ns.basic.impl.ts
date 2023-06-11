import core from "./ns.core.impl";
import {NSWebKit} from "../plugins/ns"
import {
    ParamBadgeCount,
    ParamNavigateTo,
    ParamExternalBrowse,
    ParamNavigationBarTheme,
    ClipboardData,
    ParamPhoneCall,
    NetworkStatus,
    ParamVoiceBroadcastSwitchStatus,
    GenericCallbackFunc,
    CallbackNetworkStatusChange
} from "../plugins/ns.basic";

export const basic:NSWebKit = <NSWebKit>{
    version: "1.0.0",

    setEnableDebug(enableDebug: boolean) {
        core.enableDebug = enableDebug;
    },
    
    async openAppAuthorizeSetting() {
        return await core.cordovaExec("NSBasicPlugin", "openAppAuthorizeSetting");
    },
    
    getAppInfoSync() {
        return core.cordovaExecSync("NSBasicPlugin", "getAppInfoSync");
    },
    
    async setBadgeCount(param: ParamBadgeCount) {
        return await core.cordovaExec("NSBasicPlugin", "setBadgeCount", [param]);
    },
    
    async navigateTo(param: ParamNavigateTo) {
        return await core.cordovaExec("NSBasicPlugin", "navigateTo", [param]);
    },
    
    async navigateBack() {
        return await core.cordovaExec("NSBasicPlugin", "navigateBack");
    },

    async openExternalBrowser(param: ParamExternalBrowse) {
        return await core.cordovaExec("NSBasicPlugin", "openExternalBrowser", [param]);
    },
    
    async setNavigationBarTheme(param: ParamNavigationBarTheme) {
        return await core.cordovaExec("NSBasicPlugin", "setNavigationBarTheme", [param]);
    },

    getDeviceInfoSync() {
        return core.cordovaExecSync("NSBasicPlugin", "getDeviceInfoSync");
    },

    getClipboardDataSync() {
        return core.cordovaExecSync("NSBasicPlugin", "getClipboardDataSync");
    },

    async setClipboardData(param: ClipboardData) {
        return await core.cordovaExec("NSBasicPlugin", "setClipboardData", [param]);
    },

    async makePhoneCall(param: ParamPhoneCall) {
        return await core.cordovaExec("NSBasicPlugin", "makePhoneCall", [param]);
    },

    getNetworkTypeSync() {
        var networkState = navigator.connection.type as NetworkStatus;
        return { networkType: networkState };
    },

    async getNotificationSwitchStatus() {
        return await core.cordovaExec("NSBasicPlugin", "getNotificationSwitchStatus");
    },

    async getVoiceBroadcastSwitchStatus() {
        return await core.cordovaExec("NSBasicPlugin", "getVoiceBroadcastSwitchStatus");
    },

    async setVoiceBroadcastSwitchStatus(param: ParamVoiceBroadcastSwitchStatus) {
        return await core.cordovaExec("NSBasicPlugin", "setVoiceBroadcastSwitchStatus", [param]);
    },

    async cleanWebviewCache() {
        return await core.cordovaExec("NSBasicPlugin", "cleanWebviewCache");
    },

    registerHandler(handlerName: string, handler: GenericCallbackFunc) {
        core.registerHandler(handlerName, handler);
    },

    unRegisterHandler(handlerName: string, handler: GenericCallbackFunc) {
        core.unRegisterHandler(handlerName, handler);
    },

    unRegisterHandlers(handlerName: string) {
        core.unRegisterHandlers(handlerName);
    },

    checkHandlerExist(handlerName: string) {
        return core.checkHandlerExist(handlerName);
    },

    onNetworkStatusChange(handler: GenericCallbackFunc<CallbackNetworkStatusChange>) {
        core.registerHandler(core.kNetworkStatusChangeHandlers, handler);
    },

    offNetworkStatusChange(handler: GenericCallbackFunc<CallbackNetworkStatusChange>) {
        core.unRegisterHandler(core.kNetworkStatusChangeHandlers, handler);
    },

    onAppShow(handler: GenericCallbackFunc<void>) {
        core.registerHandler(core.kAppShowHandlers, handler);
    },

    offAppShow(handler: GenericCallbackFunc<void>) {
        core.unRegisterHandler(core.kAppShowHandlers, handler);
    },

    onAppHide(handler: GenericCallbackFunc<void>) {
        core.registerHandler(core.kAppHideHandlers, handler);
    },

    offAppHide(handler: GenericCallbackFunc<void>) {
        core.unRegisterHandler(core.kAppHideHandlers, handler);
    },

    onPageShow(handler: GenericCallbackFunc<void>) {
        core.registerHandler(core.kPageShowHandlers, handler);
    },

    offPageShow(handler: GenericCallbackFunc<void>) {
        core.unRegisterHandler(core.kPageShowHandlers, handler);
    },

    onPageHide(handler: GenericCallbackFunc<void>) {
        core.registerHandler(core.kPageHideHandlers, handler);
    },

    offPageHide(handler: GenericCallbackFunc<void>) {
        core.unRegisterHandler(core.kPageHideHandlers, handler);
    },

    onRemoteNotificationReceive(handler: GenericCallbackFunc<void>) {
        core.registerHandler(core.kNotificationHandlers, handler);
    },

    offRemoteNotificationReceive(handler: GenericCallbackFunc<void>) {
        core.unRegisterHandler(core.kNotificationHandlers, handler);
    },
}