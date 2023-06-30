/******/ (() => { // webpackBootstrap
    /******/     "use strict";
    /******/     var __webpack_modules__ = ([
        /* 0 */,
        /* 1 */
        /***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

            __webpack_require__.r(__webpack_exports__);
            /* harmony export */ __webpack_require__.d(__webpack_exports__, {
                /* harmony export */   "default": () => (__WEBPACK_DEFAULT_EXPORT__),
                /* harmony export */   jsPrivateObj: () => (/* binding */ jsPrivateObj)
                /* harmony export */ });
            /* harmony import */ var _plugins_ns_core__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(2);

            const core = {
                initialized: false,
                enableDebug: false,
                messageHandlers: new Map(),
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
                cordovaExec(pluginName, apiName, arr = []) {
                    let _this = this;
                    return new Promise((resolve, reject) => {
                        if (typeof cordova == "undefined" || typeof cordova.exec == "undefined") {
                            document.addEventListener("deviceready", function () {
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
                                    }, pluginName, apiName, arr);
                            }, false);
                        }
                        else {
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
                                }, pluginName, apiName, arr);
                        }
                    });
                },
                /**
                 * 自定义同步执行函数
                 */
                cordovaExecSync(pluginName, apiName, arr = []) {
                    let isiOS = !!navigator.userAgent.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/);
                    if (isiOS) {
                        let command = "NSExecSync=" + JSON.stringify([pluginName, apiName, arr]);
                        let result = prompt(command);
                        if (typeof result == "string") {
                            return JSON.parse(result);
                        }
                        return result;
                    }
                    else {
                        let result = _plugins_ns_core__WEBPACK_IMPORTED_MODULE_0__.NSExecSync.syncExec(pluginName, apiName, arr);
                        if (typeof result == "string") {
                            return JSON.parse(result);
                        }
                        return result;
                    }
                },
                /**
                 * 注册句柄
                 */
                registerHandler(handlerName, handler) {
                    let handlerArray;
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
                unRegisterHandlers(handlerName) {
                    this.messageHandlers.delete(handlerName);
                },
                /**
                 * 移除句柄
                 */
                unRegisterHandler(handlerName, handler) {
                    let handlerArray;
                    handlerArray = this.messageHandlers.get(handlerName);
                    if (handlerArray != undefined) {
                        handlerArray.map((val, i) => {
                            if (val == handler) {
                                handlerArray.splice(i, 1);
                            }
                        });
                    }
                },
                /**
                 * 调用句柄
                 */
                callHandler(handlerName, data) {
                    //直接发送
                    let handlerArray;
                    if (handlerName) {
                        handlerArray = this.messageHandlers.get(handlerName);
                    }
                    //遍历handlerArray
                    if (handlerArray != undefined) {
                        let handler;
                        for (handler of handlerArray) {
                            try {
                                handler(data);
                            }
                            catch (exception) {
                                if (typeof console != "undefined") {
                                    if (this.enableDebug == true) {
                                        console.log("WARNING: javascript handler threw. ", exception);
                                    }
                                }
                            }
                        }
                    }
                    else {
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
                noticeNetworkStatusChange(data) {
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
                wrapAsyncResult(data) {
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
            const jsPrivateObj = {
                handleMessageFromNative(messageJSON) {
                    let message = JSON.parse(messageJSON);
                    core.callHandler(message.handlerName, message.data);
                },
                noticeUserLogin(messageJSON) {
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
                async toast(param) {
                    return await core.cordovaExec("NSBasicPlugin", "toast", [param]);
                }
            };
            /* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (core);


            /***/ }),
        /* 2 */
        /***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

            __webpack_require__.r(__webpack_exports__);
            /* harmony export */ __webpack_require__.d(__webpack_exports__, {
                /* harmony export */   NSExecSync: () => (/* binding */ NSExecSync)
                /* harmony export */ });
            var NSExecSync;


            /***/ }),
        /* 3 */
        /***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

            __webpack_require__.r(__webpack_exports__);
            /* harmony export */ __webpack_require__.d(__webpack_exports__, {
                /* harmony export */   basic: () => (/* binding */ basic)
                /* harmony export */ });
            /* harmony import */ var _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(1);

            const basic = {
                version: "1.0.0",
                setEnableDebug(enableDebug) {
                    _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].enableDebug = enableDebug;
                },
                async openAppAuthorizeSetting() {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSBasicPlugin", "openAppAuthorizeSetting");
                },
                getAppInfoSync() {
                    return _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExecSync("NSBasicPlugin", "getAppInfoSync");
                },
                async setBadgeCount(param) {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSBasicPlugin", "setBadgeCount", [param]);
                },
                async navigateTo(param) {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSBasicPlugin", "navigateTo", [param]);
                },
                async navigateBack() {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSBasicPlugin", "navigateBack");
                },
                async openExternalBrowser(param) {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSBasicPlugin", "openExternalBrowser", [param]);
                },
                async setNavigationBarTheme(param) {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSBasicPlugin", "setNavigationBarTheme", [param]);
                },
                getDeviceInfoSync() {
                    return _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExecSync("NSBasicPlugin", "getDeviceInfoSync");
                },
                getClipboardDataSync() {
                    return _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExecSync("NSBasicPlugin", "getClipboardDataSync");
                },
                async setClipboardData(param) {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSBasicPlugin", "setClipboardData", [param]);
                },
                async makePhoneCall(param) {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSBasicPlugin", "makePhoneCall", [param]);
                },
                getNetworkTypeSync() {
                    var networkState = navigator.connection.type;
                    return { networkType: networkState };
                },
                async getNotificationSwitchStatus() {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSBasicPlugin", "getNotificationSwitchStatus");
                },
                async getVoiceBroadcastSwitchStatus() {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSBasicPlugin", "getVoiceBroadcastSwitchStatus");
                },
                async setVoiceBroadcastSwitchStatus(param) {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSBasicPlugin", "setVoiceBroadcastSwitchStatus", [param]);
                },
                async cleanWebviewCache() {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSBasicPlugin", "cleanWebviewCache");
                },
                registerHandler(handlerName, handler) {
                    _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].registerHandler(handlerName, handler);
                },
                unRegisterHandler(handlerName, handler) {
                    _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].unRegisterHandler(handlerName, handler);
                },
                unRegisterHandlers(handlerName) {
                    _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].unRegisterHandlers(handlerName);
                },
                checkHandlerExist(handlerName) {
                    return _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].checkHandlerExist(handlerName);
                },
                onNetworkStatusChange(handler) {
                    _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].registerHandler(_ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].kNetworkStatusChangeHandlers, handler);
                },
                offNetworkStatusChange(handler) {
                    _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].unRegisterHandler(_ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].kNetworkStatusChangeHandlers, handler);
                },
                onAppShow(handler) {
                    _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].registerHandler(_ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].kAppShowHandlers, handler);
                },
                offAppShow(handler) {
                    _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].unRegisterHandler(_ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].kAppShowHandlers, handler);
                },
                onAppHide(handler) {
                    _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].registerHandler(_ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].kAppHideHandlers, handler);
                },
                offAppHide(handler) {
                    _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].unRegisterHandler(_ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].kAppHideHandlers, handler);
                },
                onPageShow(handler) {
                    _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].registerHandler(_ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].kPageShowHandlers, handler);
                },
                offPageShow(handler) {
                    _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].unRegisterHandler(_ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].kPageShowHandlers, handler);
                },
                onPageHide(handler) {
                    _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].registerHandler(_ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].kPageHideHandlers, handler);
                },
                offPageHide(handler) {
                    _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].unRegisterHandler(_ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].kPageHideHandlers, handler);
                },
                onRemoteNotificationReceive(handler) {
                    _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].registerHandler(_ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].kNotificationHandlers, handler);
                },
                offRemoteNotificationReceive(handler) {
                    _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].unRegisterHandler(_ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].kNotificationHandlers, handler);
                },
            };


            /***/ }),
        /* 4 */
        /***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

            __webpack_require__.r(__webpack_exports__);
            /* harmony export */ __webpack_require__.d(__webpack_exports__, {
                /* harmony export */   customCamera: () => (/* binding */ customCamera)
                /* harmony export */ });
            /* harmony import */ var _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(1);

            const customCamera = {
                async compressImage(param) {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSCustomCameraPlugin", "compressImage", [param]);
                },
                async saveImageToPhotosAlbum(param) {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSCustomCameraPlugin", "saveImageToPhotosAlbum", [param]);
                },
                async chooseImage(param) {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSCustomCameraPlugin", "chooseImage", [param]);
                }
            };


            /***/ }),
        /* 5 */
        /***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

            __webpack_require__.r(__webpack_exports__);
            /* harmony export */ __webpack_require__.d(__webpack_exports__, {
                /* harmony export */   scan: () => (/* binding */ scan)
                /* harmony export */ });
            /* harmony import */ var _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(1);

            const scan = {
                async scanCode(param) {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSScanPlugin", "scanCode", [param]);
                },
            };


            /***/ }),
        /* 6 */
        /***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

            __webpack_require__.r(__webpack_exports__);
            /* harmony export */ __webpack_require__.d(__webpack_exports__, {
                /* harmony export */   location: () => (/* binding */ location)
                /* harmony export */ });
            /* harmony import */ var _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(1);

            const location = {
                async getLocationInfo() {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSLocationPlugin", "getLocationInfo");
                },
                async chooseLocation(param) {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSChooseLocationPlugin", "chooseLocation", [param]);
                }
            };


            /***/ }),
        /* 7 */
        /***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

            __webpack_require__.r(__webpack_exports__);
            /* harmony export */ __webpack_require__.d(__webpack_exports__, {
                /* harmony export */   share: () => (/* binding */ share)
                /* harmony export */ });
            /* harmony import */ var _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(1);

            const share = {
                async sendWXAuthRequest() {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSSharePlugin", "sendWXAuthRequest");
                },
                async shareToWX(param) {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSSharePlugin", "shareToWX", [param]);
                },
                async launchWXMiniProgram(param) {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSSharePlugin", "launchWXMiniProgram", [param]);
                },
                async shareToWXMiniProgram(param) {
                    return await _ns_core_impl__WEBPACK_IMPORTED_MODULE_0__["default"].cordovaExec("NSSharePlugin", "shareToWXMiniProgram", [param]);
                }
            };


            /***/ })
        /******/     ]);
    /************************************************************************/
    /******/     // The module cache
    /******/     var __webpack_module_cache__ = {};
    /******/
    /******/     // The require function
    /******/     function __webpack_require__(moduleId) {
        /******/         // Check if module is in cache
        /******/         var cachedModule = __webpack_module_cache__[moduleId];
        /******/         if (cachedModule !== undefined) {
            /******/             return cachedModule.exports;
            /******/         }
        /******/         // Create a new module (and put it into the cache)
        /******/         var module = __webpack_module_cache__[moduleId] = {
            /******/             // no module.id needed
            /******/             // no module.loaded needed
            /******/             exports: {}
            /******/         };
        /******/
        /******/         // Execute the module function
        /******/         __webpack_modules__[moduleId](module, module.exports, __webpack_require__);
        /******/
        /******/         // Return the exports of the module
        /******/         return module.exports;
        /******/     }
    /******/
    /************************************************************************/
    /******/     /* webpack/runtime/define property getters */
    /******/     (() => {
        /******/         // define getter functions for harmony exports
        /******/         __webpack_require__.d = (exports, definition) => {
            /******/             for(var key in definition) {
                /******/                 if(__webpack_require__.o(definition, key) && !__webpack_require__.o(exports, key)) {
                    /******/                     Object.defineProperty(exports, key, { enumerable: true, get: definition[key] });
                    /******/                 }
                /******/             }
            /******/         };
        /******/     })();
    /******/
    /******/     /* webpack/runtime/hasOwnProperty shorthand */
    /******/     (() => {
        /******/         __webpack_require__.o = (obj, prop) => (Object.prototype.hasOwnProperty.call(obj, prop))
        /******/     })();
    /******/
    /******/     /* webpack/runtime/make namespace object */
    /******/     (() => {
        /******/         // define __esModule on exports
        /******/         __webpack_require__.r = (exports) => {
            /******/             if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
                /******/                 Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
                /******/             }
            /******/             Object.defineProperty(exports, '__esModule', { value: true });
            /******/         };
        /******/     })();
    /******/
    /************************************************************************/
    var __webpack_exports__ = {};
// This entry need to be wrapped in an IIFE because it need to be isolated against other modules in the chunk.
    (() => {
        __webpack_require__.r(__webpack_exports__);
        /* harmony import */ var _impl_ns_core_impl__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(1);
        /* harmony import */ var _impl_ns_basic_impl__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(3);
        /* harmony import */ var _impl_ns_customCamera_impl__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(4);
        /* harmony import */ var _impl_ns_scan_impl__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(5);
        /* harmony import */ var _impl_ns_location_impl__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(6);
        /* harmony import */ var _impl_ns_share_impl__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(7);
        const TAG = "com.nswebkit.ts";
        console.log(TAG, "start");






        const ns = {
            ..._impl_ns_core_impl__WEBPACK_IMPORTED_MODULE_0__.jsPrivateObj,
            ..._impl_ns_basic_impl__WEBPACK_IMPORTED_MODULE_1__.basic,
            ..._impl_ns_customCamera_impl__WEBPACK_IMPORTED_MODULE_2__.customCamera,
            ..._impl_ns_scan_impl__WEBPACK_IMPORTED_MODULE_3__.scan,
            ..._impl_ns_location_impl__WEBPACK_IMPORTED_MODULE_4__.location,
            ..._impl_ns_share_impl__WEBPACK_IMPORTED_MODULE_5__.share,
        };
        function spIsReady() {
            const readyEvent = new Event("NSReady");
            document.dispatchEvent(readyEvent);
        }
        if (!window.ns) {
            window.ns = ns;
            spIsReady();
        }

    })();

    /******/ })()
;
