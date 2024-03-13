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
    CallbackNetworkStatusChange,
    ParamStorage,
    ParamRemoveStorage,
    ParamStorageClear,
    ParamOpenFileInfo,
    ParamWaterMarkInfo, ParamConvertImagePathToBase64, ParamOpenAppPage
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

    setStorageSync(key: string, data: any, groupName?: string, validSecond?: number) {
        let value = core.cordovaExecSync("NSBasicPlugin", "setStorageSync", [{ "key": key, "data": data, "groupName": groupName, "validSecond": validSecond }]);
        return value["data"];
    },

    async setStorage(param: ParamStorage) {
        return await core.cordovaExec("NSBasicPlugin", "setStorage", [param]);
    },

    getStorageSync(key: string, groupName?: string) {
        let value = core.cordovaExecSync("NSBasicPlugin", "getStorageSync", [{ "key": key, "groupName": groupName }]);
        return value["data"];
    },

    async getStorage(param: ParamStorage) {
        return await core.cordovaExec("NSBasicPlugin", "getStorage", [param]);
    },

    removeStorageSync(key: string, groupName?: string) {
        core.cordovaExecSync("NSBasicPlugin", "removeStorageSync", [{ "key": key, "groupName": groupName }]);
    },

    async removeStorage(param: ParamRemoveStorage) {
        return await core.cordovaExec("NSBasicPlugin", "removeStorage", [param]);
    },

    clearStorageSync(groupName?: string) {
        core.cordovaExecSync("NSBasicPlugin", "clearStorageSync", [{ "groupName": groupName }]);
    },

    async clearStorage(param?: ParamStorageClear) {
        return await core.cordovaExec("NSBasicPlugin", "clearStorage", [param]);
    },

    async openFile(param?: ParamOpenFileInfo) {
        return await core.cordovaExec("NSBasicPlugin", "openFile", [param]);
    },

    async addWaterMark(param?: ParamWaterMarkInfo) {
        return await core.cordovaExec("NSBasicPlugin", "addWaterMark", [param]);
    },

    async convertImagePathToBase64(param?: ParamConvertImagePathToBase64) {
        return await core.cordovaExec("NSBasicPlugin", "convertImagePathToBase64", [param]);
    },

    async openNativePage(param: ParamOpenAppPage) {
        return await core.cordovaExec("NSBasicPlugin", "openNativePage", [param]);
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