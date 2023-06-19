# NSWebKit 概括
## 1.应用场景
随着大前端技术体系的完善，以及小程序的普及，在越来越多的业务中展现出了它的优势。
NSWebKit就是针对这一Native/H5的混合开发场景研发的，我们为 web开发者提供了类似主流小程序一样的研发体验。

## 2.框架设计
### 底层技术
关于H5和Native之间通信,我们选用的是Cordova开源移动框架.
Cordova是一套开源移动开发框架，开发者可以通过它用标准WEB技术：HTML5、CSS3、JavaScript，来开发跨平台App。 
Cordova目前支持的平台有：Android、 Blackberry 10、iOS、OS X、Ubuntu、Windows、WP8.

## 3.使用说明
### H5 接入说明
#### js 项目：
无需引入

#### ts 项目：
*注意：不同的发开工具和版本，及 ts版本，声明配置可能有细微区别，具体方式以项目实际情况为准。
下面为举例方法：
##### 方法一：
1. 在全局声明出配置并按需引入我们jsbridge中打包好的 .d.ts 声明文件
2. tsconfig.json types 配置

##### 方法二：
搭建 npm 私有库，将.d.ts 声明文件 自行上传，通过:
npm i @types/xxx --save 引入项目

### 插件分类
插件分为两类:
* 基础功能类插件 NBasicPlugin
```javascript
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
```

* 用户照片类插件 NSCustomCameraPlugin
```javascript
/**
 * 压缩图片
 **/
compressImage(param: ParamCompressImage): Promise<GenericAsyncResult<ReturnCompressImageResult>>;
/**
 * 保存图片到相册
 **/
saveImageToPhotosAlbum(param: ParamImageToPhotosAlbum): Promise<GenericAsyncResult<undefined>>;

/**
 * 选择照片
 **/
chooseImage(param: ParamChooseImage): Promise<GenericAsyncResult<ReturnChooseImageResult>>;
```

* 用户扫码类插件 NSScanPlugin
```javascript
/**
 * 扫码
 **/
scanCode(param: ParamScanCode): Promise<GenericAsyncResult<ReturnScanCode>>;
```

* 用户定位类插件 NSLocationPlugin
需要自行接入并配置第三方appid
```javascript
/**
 * 获取定位
 **/
getLocationInfo(): Promise<GenericAsyncResult<ReturnLocationInfo>>;
```

* 用户微信分享类插件 NSSharePlugin
  需要自行接入并配置第三方appid
```javascript
/**
 * 微信授权,并返回用户信息
 **/
sendWXAuthRequest(): Promise<GenericAsyncResult<ReturnWXAuthResult>>;
/**
 * 微信分享
 **/
shareToWX(param: ParamShareToWX): Promise<GenericAsyncResult<undefined>>;
/**
 * 打开微信小程序
 **/
launchWXMiniProgram(param: ParamOpenWXMiniProgram): Promise<GenericAsyncResult<ReturnOpenWXMiniProgramResult>>;
/**
 * 微信分享小程序
 **/
shareToWXMiniProgram(param: ParamShareToWXMiniProgram): Promise<GenericAsyncResult<undefined>>;
```

### 监听方法
除了插件所支持的方法,我们还提供了一些基础的监听方法
```javascript
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
```
### H5 调用客户端提供的插件方法
H5 调用客户端提供的插件方法分为两类

* 异步调用方式
```javascript
ns.openAppAuthorizeSetting().then((result)=>{
    console.log(result);
});
```
异步调用 采用的是Cordova提供的调用方式.

* 同步调用方式 
```javascript
var appinfo = ns.getAppInfoSync()
```
由于Cordova不支持同步调用,所以通过其他方式解决.
```javascript
    //NS.js
    function cordovaExecSync(pluginName, apiName, arr = []) {
        let isiOS = !!navigator.userAgent.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/);
        if (isiOS == true) {
            let command = "NSExecSync=" + JSON.stringify([pluginName, apiName, arr]);
            let result = prompt(command);
            if (typeof (result) == 'string') {
                return JSON.parse(result);
            }
            return result;
        }
        else {
            let result = NSExecSync.syncExec(pluginName, apiName, arr);
            if (typeof (result) == 'string') {
                return JSON.parse(result);
            }
            return result;
        }
    }
```

iOS实现方式:
拦截window.prompt()方法,用来实现同步方法
具体实现详见 CDVWKWebViewUIDelegate.m
```oc
- (void)webView:(WKWebView*)webView runJavaScriptTextInputPanelWithPrompt:(NSString*)prompt
          defaultText:(NSString*)defaultText initiatedByFrame:(WKFrameInfo*)frame
    completionHandler:(void (^)(NSString* result))completionHandler {
    NSString * prefix=@"NSExecSync=";
    if ([prompt hasPrefix:prefix]) {
        NSArray *result = [prompt componentsSeparatedByString:prefix];
        NSArray *jsonEntry = [[result lastObject] cdv_JSONObject];

        BOOL (^validationCommandArguments)(NSArray* arguments) = ^(NSArray *arr){
            if (arr.count < 2) {
                return NO;
            }
            NSString* _className = arr[0];
            NSString* _methodName = arr[1];
            NSArray* _arguments = arr[2];
            if (![_className isKindOfClass:[NSString class]] || ![_methodName isKindOfClass:[NSString class]] ) {
                return NO;
            }
            if (_arguments != nil && ![_arguments isKindOfClass:[NSArray class]]) {
                return NO;
            }
            
            return YES;
        };

        if(validationCommandArguments(jsonEntry) == NO) {
            NSDictionary *result = @{@"errcode":@"1",@"errorMsg":@"数据格式不正确"};
            completionHandler([result cdv_JSONString]);
            return ;
        }
        else{
        ....
        }
}
```
Android实现方式:
在Cordova初始化的时候 增加JavascriptInterface
具体实现详见 NSCordovaView.java
```java
private void initCordova() {
    this.appView = this.makeWebView();
    this.createViews();
    if (!this.appView.isInitialized()) {
        this.appView.init(this.cordovaInterface, this.pluginEntries, this.preferences);
    }

    if (null != this.appView.getPluginManager().getPlugin("NSBasicPlugin")) {
        ((NSBasicPlugin)this.appView.getPluginManager().getPlugin("NSBasicPlugin")).setSpCordovaView(this);
    }

    NSSyncExposedJsApi syncExposedJsApi = new NSSyncExposedJsApi(new NSJsBridge(this.appView.getPluginManager()));
    this.getWebview().addJavascriptInterface(syncExposedJsApi, "NSExecSync");
    this.cordovaInterface.onCordovaInit(this.appView.getPluginManager());
}
```

### 客户端 调用H5提供的插件方法
首先H5先注册一个方法
```javascript
/**
* H5 注册一个句柄,提供给Native调用
**/
ns.registerHandler("h5Callback", function(data){});
```
客户端调用

iOS:
```
WKWebView *wkWebView = (WKWebView *)self.webView;
NSDictionary *dic = @{ @"handlerName": @"h5Callback", @"data": @{ @"actionTxt": actionTxt } };
[wkWebView evaluateJavaScript:[NSString stringWithFormat:@"ns.handleMessageFromNative('%@')", [dic jsonStringEncoded]] completionHandler:^(id _Nullable obj, NSError *_Nullable error) {
}];
    
```

Android:
```java
JSONObject jsonObject = new JSONObject();
JSONObject actionObject = new JSONObject();

try {
        actionObject.put("actionTxt", this.actionTxt);
        jsonObject.put("handlerName", "h5Callback");
        jsonObject.put("data", actionObject);
    } catch (JSONException var5) {
        var5.printStackTrace();
    }

this.mCordovaView.getWebview().evaluateJavascript("ns.handleMessageFromNative('" + jsonObject + "')", (ValueCallback)null);

```



