import type {GenericAsyncResult} from "./ns";

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
    titleColor?: string; //16进制标题文字颜色，如: #eeeeee
    color?: string;
    isBright?: boolean; //
    showBackButton?: boolean;
    showCloseButton?: boolean;
    actionTxt?: string;//右上角文字按钮
    actionIcon?: string;//右上角 icon base64
    translucentStatusBars?: boolean;//状态栏是否沉浸
};
export declare type ParamExternalBrowse = {
    url: string;
};
export declare type ParamNavigationBarTheme = {
    hidden?: boolean;
    title?: string;
    titleColor?: string; //16进制标题文字颜色，如 eeeeee
    color?: string;
    isBright?: boolean; //
    showBackButton?: boolean;
    showCloseButton?: boolean;
    actionTxt?: string;//右上角文字按钮
    actionIcon?: string;//右上角 icon base64
    translucentStatusBars?: boolean;//状态栏是否沉浸
};
export declare type ParamPhoneCall = {
    phoneNumber: string;
};
export declare type ReturnAppInfo = {
    appId: string;
    appVersionName: string;
    appVersionCode: number;
    extendInfo?: any;//扩展信息字段
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
export declare type CallbackNetworkStatusChange = {
    networkType: NetworkStatus;
};
export declare type ParamVoiceBroadcastSwitchStatus = {
    status: boolean;
};
export declare type ReturnVoiceBroadcastSwitchStatus = {
    status: boolean;
};
export declare type ParamStorage = {
    groupName?: string;
    key: string;
    data: any;
};
export declare type ParamRemoveStorage = {
    groupName?: string;
    key: string;
};
export declare type ReturnStorageResult = {
    data: any;
};
export declare type ParamStorageClear = {
    groupName?: string;
};
export declare type ParamOpenFileInfo = {
    /** 文件地址 */
    url: string;
    /** fileName 必须包含后缀 . 为空时从url里截取 */
    fileName?: string;
};
export const enum SPWaterMarkPosition {
    /** 左上 */
    SPWaterMarkLeftTop = 0,
    /** 右上 */
    SPWaterMarkRightTop = 1,
    /** 左下 */
    SPWaterMarkLeftBottom = 2,
    /** 右下 */
    SPWaterMarkRightBottom = 3,
    /** 居中 */
    SPWaterMarkCenter = 4
}
export declare type ParamWaterMarkInfo = {
    /** 水印文字 */
    text: string;
    /**
     * 图片base64
     **/
    base64Image?: string;
    /**
     * 图片路径 和 图片base64 二选一 优先使用路径
     **/
    imagePath?: string;
    /**
     * 文字颜色 #000000 默认#000000
     **/
    color?: string;
    /**
     * 文字背景颜色 默认透明
     **/
    backgroundColor?: string;
    /**
     * 背景圆角
     **/
    cornerRadius?: number;
    /**
     * 文字大小
     **/
    fontSize?: number;
    /**
     * 水印位置 默认 右下
     **/
    position?: SPWaterMarkPosition
    /**
     * 外边距 默认8像素 如果居中,边距不生效
     **/
    margin?: number;
    /**
     * 内边距 默认8像素
     **/
    padding?: number;
};
export declare type ReturnAddWaterMarkResult = {
    /**
     * 添加水印之后的图片路径
     **/
    path?: string;
};
export declare type ParamConvertImagePathToBase64 = {
    /**
     * 图片路径
     **/
    path: string;
};
export declare type ReturnConvertImagePathToBase64Result = {
    /**
     * 图片 base64
     **/
    base64Image?: string;
};
export declare type ParamOpenAppPage = {
    pageName: string;
    extInfo?: any
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
        setVoiceBroadcastSwitchStatus(
            param: ParamVoiceBroadcastSwitchStatus
        ): Promise<GenericAsyncResult<ReturnVoiceBroadcastSwitchStatus>>;
        /**
         * 清理webview缓存
         */
        cleanWebviewCache(): Promise<GenericAsyncResult<undefined>>;
        /**
         * 同步存储
         **/
        setStorageSync(key: string, data: any, groupName?: string, validSecond?: number): void;
        /**
         * 异步存储
         **/
        setStorage(param: ParamStorage): Promise<GenericAsyncResult<undefined>>;
        /**
         * 同步获取存储
         **/
        getStorageSync(key: string, groupName?: string): any;
        /**
         * 异步获取存储
         **/
        getStorage(param: ParamStorage): Promise<GenericAsyncResult<ReturnStorageResult>>;
        /**
         * 同步移除存储
         **/
        removeStorageSync(key: string, groupName?: string): void;
        /**
         * 移除存储
         **/
        removeStorage(param: ParamRemoveStorage): Promise<GenericAsyncResult<undefined>>;
        /**
         * 同步清除存储
         **/
        clearStorageSync(key: string, groupName?: string): void;
        /**
         * 清除存储
         **/
        clearStorage(param?: ParamStorageClear): Promise<GenericAsyncResult<undefined>>;
        /**
         * 打开PDF文件
         **/
        openFile(param?: ParamOpenFileInfo): Promise<GenericAsyncResult<undefined>>;
        /**
         * 图片添加水印
         **/
        addWaterMark(param?: ParamWaterMarkInfo): Promise<GenericAsyncResult<ReturnAddWaterMarkResult>>;
        /**
         * 本地图片path 转 base64
         **/
        convertImagePathToBase64(param?: ParamConvertImagePathToBase64): Promise<GenericAsyncResult<ReturnConvertImagePathToBase64Result>>;
        /**
         * 跳转App原生界面
         **/
        openNativePage(param: ParamOpenAppPage): Promise<GenericAsyncResult<undefined>>;
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