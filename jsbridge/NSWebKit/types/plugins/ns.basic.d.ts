export declare type NetworkStatus = "wifi" | "2g" | "3g" | "4g" | "5g" | "ethernet" | "none" | "unknown";
export declare type ClipboardData = {
    data: string;
};
export declare type ParamBadgeCount = {
    count: number;
};
export declare type ParamNavigateTo = {
    url: string;
    hidden?: boolean;
    title?: string;
    titleColor?: string;
    color?: string;
    isBright?: boolean;
    showBackButton?: boolean;
    showCloseButton?: boolean;
    actionTxt?: string;
    actionIcon?: string;
    translucentStatusBars?: boolean;
};
export declare type ParamExternalBrowse = {
    url: string;
};
export declare type ParamNavigationBarTheme = {
    hidden?: boolean;
    title?: string;
    titleColor?: string;
    color?: string;
    isBright?: boolean;
    showBackButton?: boolean;
    showCloseButton?: boolean;
    actionTxt?: string;
    actionIcon?: string;
    translucentStatusBars?: boolean;
};
export declare type ParamPhoneCall = {
    phoneNumber: string;
};
export declare type ReturnAppInfo = {
    appId: string;
    appVersionName: string;
    appVersionCode: number;
    extendInfo?: any;
};
export declare type ReturnDeviceInfo = {
    osType: number;
    osVersion: string;
    model: string;
    brand: string;
    deviceId: string;
    imei: string;
    statusBarHeight: number;
};
export declare type ReturnNetworkType = {
    networkType: NetworkStatus;
};
export declare type ReturnNotiSwitchStatus = {
    status: boolean;
};
export declare type GenericCallbackFunc<T = any> = (data: T) => void;
export type CallbackNetworkStatusChange = {
    networkType: NetworkStatus;
};
export declare type ParamVoiceBroadcastSwitchStatus = {
    status: boolean;
};
export declare type ReturnVoiceBroadcastSwitchStatus = {
    status: boolean;
};
declare module "./ns" {
    interface NSWebKit {
        /**
         * 版本号
         */
        version: string;
        /**
         * 设置是否打开调试开关。
         */
        setEnableDebug(enableDebug: boolean): void;
        /**
         * 跳转当前App的系统授权管理⻚
         */
        openAppAuthorizeSetting(): Promise<GenericAsyncResult<undefined>>;
        /**
         * 获取当前App相关信息
         */
        getAppInfoSync(): ReturnAppInfo;
        /**
         * 在App应用图标上显示数字⻆标
         */
        setBadgeCount(param: ParamBadgeCount): Promise<GenericAsyncResult<undefined>>;
        /**
         * 打开新页面
         */
        navigateTo(param: ParamNavigateTo): Promise<GenericAsyncResult<undefined>>;
        /**
         * 返回上一级
         *
         */
        navigateBack(): Promise<GenericAsyncResult<undefined>>;
        /**
         * 用外部浏览器打开⻚面
         */
        openExternalBrowser(param: ParamExternalBrowse): Promise<GenericAsyncResult<undefined>>;
        /**
         * 设置WebView容器⻚面的导航栏主题
         */
        setNavigationBarTheme(param: ParamNavigationBarTheme): Promise<GenericAsyncResult<undefined>>;
        /**
         * 获取设备相关信息
         */
        getDeviceInfoSync(): ReturnDeviceInfo;
        /**
         * 获取系统剪贴板的内容
         */
        getClipboardDataSync(): ClipboardData;
        /**
         * 设置系统剪贴板的内容
         */
        setClipboardData(param: ClipboardData): Promise<GenericAsyncResult<undefined>>;
        /**
         * 拨打电话
         */
        makePhoneCall(param: ParamPhoneCall): Promise<GenericAsyncResult<undefined>>;
        /**
         * 获取设备网络状态
         */
        getNetworkTypeSync(): ReturnNetworkType;
        /**
         * 获取推送权限开关状态
         */
        getNotificationSwitchStatus(): Promise<GenericAsyncResult<ReturnNotiSwitchStatus>>;
        /**
         * 读取语音播报开关状态
         */
        getVoiceBroadcastSwitchStatus(): Promise<GenericAsyncResult<ReturnVoiceBroadcastSwitchStatus>>;
        /**
         * 设置语音播报开关状态
         */
        setVoiceBroadcastSwitchStatus(param: ParamVoiceBroadcastSwitchStatus): Promise<GenericAsyncResult<ReturnVoiceBroadcastSwitchStatus>>;
        /**
         * 清理webview缓存
         */
        cleanWebviewCache(): Promise<GenericAsyncResult<undefined>>;
        /**
         * H5 注册一个句柄,提供给Native调用
         */
        registerHandler(handlerName: string, handler: GenericCallbackFunc): void;
        /**
         * 解绑某个handleName下的所有句柄
         */
        unRegisterHandlers(handlerName: string): void;
        /**
         * 解绑句柄
         */
        unRegisterHandler(handlerName: string, handler: GenericCallbackFunc): void;
        /**
         * 检查 H5 是否已经注册句柄。native内部会调用
         */
        checkHandlerExist(handlerName: string): boolean;
        /**
         * 监听网络状态变化
         */
        onNetworkStatusChange(handler: GenericCallbackFunc<CallbackNetworkStatusChange>): void;
        /**
         * 移除监听网络状态变化
         */
        offNetworkStatusChange(handler: GenericCallbackFunc<CallbackNetworkStatusChange>): void;
        /**
         * 监听App切前台事件
         */
        onAppShow(handler: GenericCallbackFunc<void>): void;
        /**
         * 移除监听App切前台事件
         */
        offAppShow(handler: GenericCallbackFunc<void>): void;
        /**
         * 监听App切后台台事件
         */
        onAppHide(handler: GenericCallbackFunc<void>): void;
        /**
         * 移除监听App切后台事件
         */
        offAppHide(handler: GenericCallbackFunc<void>): void;
        /**
         * 监听App Push Notification事件
         */
        onRemoteNotificationReceive(handler: GenericCallbackFunc<void>): void;
        /**
         * 移除App Push Notification事件
         */
        offRemoteNotificationReceive(handler: GenericCallbackFunc<void>): void;
        /**
         * 监听Page显示事件
         */
        onPageShow(handler: GenericCallbackFunc<void>): void;
        /**
         * 移除监听Page显示事件
         */
        offPageShow(handler: GenericCallbackFunc<void>): void;
        /**
         * 监听Page消失事件
         */
        onPageHide(handler: GenericCallbackFunc<void>): void;
        /**
         * 移除监听Page消失事件
         */
        offPageHide(handler: GenericCallbackFunc<void>): void;
    }
}
