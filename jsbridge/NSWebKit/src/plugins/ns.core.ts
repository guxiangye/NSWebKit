import type {GenericCallbackFunc} from "./ns.basic";

declare interface NSExecSyncInterFace {
    syncExec(pluginName: string, apiName: string, arr: any[]): any;
}

export declare type Core = {
    initialized: boolean;
    enableDebug: boolean;
    messageHandlers: Map<string, Array<Function>>;

    kNetworkStatusChangeHandlers: string;
    kUserLoginHandlers: string;
    kUserLogoutHandlers: string;
    kAppShowHandlers: string;
    kAppHideHandlers: string;
    kPageShowHandlers: string;
    kPageHideHandlers: string;
    kNotificationHandlers: string;

    cordovaExec: (pluginName: string, apiName: string, arr?: any[]) => Promise<any>;
    cordovaExecSync: (pluginName: string, apiName: string, arr?: any[]) => any;
    noticeNetworkStatusChange(data: any): void;
    registerHandler(handlerName: string, handler: GenericCallbackFunc): void;
    unRegisterHandlers(handlerName: string): void;
    unRegisterHandler(handlerName: string, handler: GenericCallbackFunc): void;
    checkHandlerExist(handlerName: string): boolean;
    callHandler(handlerName: string, data: any): void;
    noticeAppShow(): void;
    noticeAppHide(): void;
    noticePageShow(): void;
    noticePageHide(): void;
    wrapAsyncResult(data: any): any;
};

export var NSExecSync: NSExecSyncInterFace;

declare global {
    interface Navigator {
        connection: { type: string };
    }
}