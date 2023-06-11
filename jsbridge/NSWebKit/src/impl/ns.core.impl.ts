import {core, NSExecSync} from "../plugins/ns.core"
import {GenericCallbackFunc} from "../plugins/ns.basic";

const core: core = <core>{
    initialized: false,
    enableDebug: false,
    messageHandlers: new Map<string, Function[]>(),
    kNetworkStatusChangeHandlers: "NetworkStatusChangeHandlers",
    kUserLoginHandlers: "UserLoginHandlers",
    kUserLogoutHandlers: "UserLogoutHandlers",
    kAppShowHandlers: "AppShowHandlers",
    kAppHideHandlers: "AppHideHandlers",
    kPageShowHandlers: "PageShowHandlers",
    kPageHideHandlers: "PageHideHandlers",
    kNotificationHandlers: "NotificationHandlers",
    /**
     * cordova 异步执行函数
     */
    cordovaExec(pluginName: string, apiName: string, arr: any[] = []) {
        let _this = this;

        return new Promise((resolve, reject) => {
            if (typeof cordova == "undefined" || typeof cordova.exec == "undefined") {
                document.addEventListener(
                    "deviceready",
                    function () {
                        cordova.exec(
                            // cordova 成功的回调
                            data => {
                                if (_this.enableDebug == true) {
                                    console.log("cordova 调用 " + pluginName + " " + apiName + " 成功");
                                }
                                const retVal = _this.wrapAsyncResult(data);
                                resolve(retVal);
                            },
                            // cordova 失败的回调
                            resaon => {
                                if (_this.enableDebug == true) {
                                    console.log("cordova 调用 " + pluginName + " " + apiName + " 失败");
                                }
                                reject(resaon);
                            },
                            pluginName,
                            apiName,
                            arr
                        );
                    },
                    false
                );
            } else {
                cordova.exec(
                    // cordova 成功的回调
                    data => {
                        if (_this.enableDebug == true) {
                            console.log("cordova 调用 " + pluginName + " " + apiName + " 成功");
                        }
                        const retVal = _this.wrapAsyncResult(data);
                        resolve(retVal);
                    },
                    // cordova 失败的回调
                    resaon => {
                        if (_this.enableDebug == true) {
                            console.log("cordova 调用 " + pluginName + " " + apiName + " 失败");
                        }
                        reject(resaon);
                    },
                    pluginName,
                    apiName,
                    arr
                );
            }
        });
    },
    /**
     * 自定义同步执行函数
     */
    cordovaExecSync(pluginName: string, apiName: string, arr: any[] = []) {
        let isiOS: boolean = !!navigator.userAgent.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/);
        if (isiOS) {
            let command = "NSExecSync=" + JSON.stringify([pluginName, apiName, arr]);
            let result = prompt(command);
            if (typeof result == "string") {
                return JSON.parse(result);
            }
            return result;
        } else {
            let result: JSON = NSExecSync.syncExec(pluginName, apiName, arr);
            if (typeof result == "string") {
                return JSON.parse(result);
            }
            return result;
        }
    },
    /**
     * 注册句柄
     */
    registerHandler(handlerName: string, handler: GenericCallbackFunc) {
        let handlerArray: Array<Function> | undefined;
        handlerArray = this.messageHandlers.get(handlerName);
        if (handlerArray == undefined) {
            handlerArray = new Array();
        }
        if (handlerArray.indexOf(handler) > -1) {
            return;
        }
        handlerArray.push(handler);
        this.messageHandlers.set(handlerName, handlerArray);
    },
    /**
     * 移除name下全部句柄
     */
    unRegisterHandlers(handlerName: string) {
        this.messageHandlers.delete(handlerName);
    },
    /**
     * 移除句柄
     */
    unRegisterHandler(handlerName: string, handler: GenericCallbackFunc) {
        let handlerArray: Array<Function> | undefined;
        handlerArray = this.messageHandlers.get(handlerName);
        if (handlerArray != undefined) {
            handlerArray.map((val, i) => {
                if (val == handler) {
                    (handlerArray as Array<Function>).splice(i, 1);
                }
            });
        }
    },
    /**
     * 调用句柄
     */
    callHandler(handlerName: string, data: any) {
        //直接发送
        let handlerArray: Array<Function> | undefined;
        if (handlerName) {
            handlerArray = this.messageHandlers.get(handlerName);
        }
        //遍历handlerArray
        if (handlerArray != undefined) {
            let handler: Function;
            for (handler of handlerArray) {
                try {
                    handler(data);
                } catch (exception) {
                    if (typeof console != "undefined") {
                        if (this.enableDebug == true) {
                            console.log("WARNING: javascript handler threw. ", exception);
                        }
                    }
                }
            }
        } else {
            if (typeof console != "undefined") {
                if (this.enableDebug == true) {
                    console.log("WARNING: javascript handler not found.", handlerName, data);
                }
            }
        }
    },
    /**
     * 网络环境改变
     */
    noticeNetworkStatusChange(data: any) {
        this.callHandler(this.kNetworkStatusChangeHandlers, data);
    },
    /**
     * 通知 App 进入前台
     */
    noticeAppShow() {
        this.callHandler(this.kAppShowHandlers, null);
    },
    /**
     * 通知 App 进入后台
     */
    noticeAppHide() {
        this.callHandler(this.kAppHideHandlers, null);
    },
    /**
     * 通知 Page 显示
     */
    noticePageShow() {
        this.callHandler(this.kPageShowHandlers, null);
    },
    /**
     * 通知 Page 消失
     */
    noticePageHide() {
        this.callHandler(this.kPageHideHandlers, null);
    },
    wrapAsyncResult(data: any) {
        const errCode = data.errCode;
        const errorMsg = data.errorMsg;
        delete data.errCode;
        delete data.errorMsg;
        return {
            errCode,
            errorMsg,
            result: data
        };
    }
};

export const jsPrivateObj = {
    handleMessageFromNative(messageJSON: string) {
        let message = JSON.parse(messageJSON);
        core.callHandler(message.handlerName, message.data);
    },

    noticeUserLogin(messageJSON: string) {
        var userInfo = JSON.parse(messageJSON);
        core.callHandler(core.kUserLoginHandlers, userInfo);
    },

    noticeUserLogout() {
        core.callHandler(core.kUserLogoutHandlers, null);
    },

    noticePageShow() {
        core.noticePageShow();
    },
    noticePageHide() {
        core.noticePageHide();
    },

    async toast(param: { msg: string }): Promise<any> {
        return await core.cordovaExec("NSBasicPlugin", "toast", [param]);
    }
};

export default core;