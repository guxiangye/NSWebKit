# 容器化 APP Native端设计概括
## 1.背景和目标
当前，各个业务的移动App产品，都是以“Native + H5”的混合开发模式来实现的。对ToC类产品，为了保证用户体 验，倾向于使用native来实现大部分主体业务功能;而对ToB类产品，可以考虑使用H5实现业务，从而在迭代上获 得更多的灵活性。
无论是哪一种类型，都会有H5业务接入移动App的诉求。我们以“平台”的视⻆来看待并思考移动App，这种接入就 像“微信小程序接入微信”一样。于是，我们将一个个的H5业务定义为"H5小应用(applet)"，移动App作为平台(也 称为容器)，需要向这些小应用提供运行所需的“WebView宿主环境”，并开放native业务相关的调用API。另外， 容器App需要实现用户登录组件，H5小应用可获取容器内的用户信息完成自身的联合登录。

## 2.框架设计
### 关于H5和Native之间通信,我们选用的是Cordova开源移动框架.
#### Cordova 介绍
Cordova是一套开源移动开发框架，隶属于Apache开源项目，通过它，开发者可以用标准WEB技术：HTML5、CSS3、JavaScript，来开发跨平台App。 Cordova目前支持的平台有：Android、 Blackberry 10、iOS、OS X、Ubuntu、Windows、WP8.
#### Cordova 选用理由
Cordova 是一套非常成熟,并且被广泛使用的开发框架!除了官方提供的插件外,仍然有大量第三方插件,满足不同的业务开发.之所以我们不使用基于Flutter端webview实现的JSBridge,是考虑到,我们部分APP可能只需要H5显示,而不需要其他页面显示,把Flutter集成进去会使APP变得臃肿!

## 3.使用说明
### H5 接入说明
H5 想使用容器化APP提供的方法,需要在head里引入一个JS文件 http://www.xxxxxx.xxx/ns.js
这段JS文件 会在document对象上挂载一个对象ns. 后续H5 就可以通过ns.xxx() 去使用容器化APP所支持的方法.
备注: 这个JS文件如果不引入,会导致Android端无法在H5刚开始载入的时候调用ns方法. (在页面加载完成之后,客户端会自动注入这段js,依旧是可以调用ns的方法的)

### Cordova 插件分类
插件分为两类:
* 基础功能类插件 NSLoginPlugin
```javascript
/**
 * toast
 **/
toast(param?: {}): Promise<any>;
/**
 * 跳转当前App的系统授权管理⻚
 **/
openAppAuthorizeSetting(): Promise<any>;
/**
 * 获取当前App相关信息
 **/
getAppInfoSync(): any;
/**
 * 在App应用图标上显示数字⻆标
 **/
setBadgeCount(param?: {}): Promise<any>;
/**
 * 打开新页面
 **/
navigateTo(param?: {}): Promise<any>;
/**
 * 返回上一级
 **/
navigateBack(): Promise<any>;
/**
 * 用外部浏览器打开⻚面
 **/
openExternalBrowser(param?: {}): Promise<any>;
/**
 * 设置WebView容器⻚面的导航栏主题
 **/
setNavigationBarTheme(param?: {}): Promise<any>;
/**
 * 获取设备相关信息
 **/
getDeviceInfoSync(): any;
/**
 * 获取系统剪贴板的内容
 **/
getClipboardDataSync(): any;
/**
 * 设置系统剪贴板的内容
 **/
setClipboardData(param?: {}): Promise<any>;
/**
 * 拨打电话
 **/
makePhoneCall(param?: {}): Promise<any>;
/**
 * 获取设备网络状态
 **/
getNetworkTypeSync(): {
    networkType: ConnectionType;
    errCode: number;
};
/**
 * 扫码
 **/
scanCode(param?: {}): Promise<any>;
/**
 * 保存图片到相册
 **/
saveImageToPhotosAlbum(param?: {}): Promise<any>;
    
```

* 用户登录功能类插件 NSBasicPlugin
```javascript
/**
 * 登录
 **/
login(): Promise<any>;
/**
 * 退出登录
 **/
logOut(): Promise<any>;
/**
 * 获取当前登录用户的信息
 **/
getUserInfoSync(): Promise<any>;
```



### 监听方法
除了插件所支持的方法,我们还提供了一些基础的监听方法
```javascript
 /**
 * 监听网络状态变化
 **/
onNetworkStatusChange(handler: Function): void;
/**
 * 移除监听网络状态变化
 **/
offNetworkStatusChange(handler: Function): void;
/**
 * 监听用户登录成功事件
 **/
onUserLogin(handler: Function): void;
/**
 * 移除监听用户登录成功事件
 **/
offUserLogin(handler: Function): void;
 /**
 * 监听用户登出的事件
 **/
onUserLogout(handler: Function): void;
/**
 * 移除监听用户登出的事件
 **/
offUserLogout(handler: Function): void;
/**
 * 监听App切前台事件
 **/
onAppShow(handler: Function): void;
/**
 * 移除监听App切前台事件
 **/
offAppShow(handler: Function): void;
```
### H5 调用客户端提供的插件方法
H5 调用客户端提供的插件方法分为两类

* 异步调用方式
```javascript
ns.openAppAuthorizeSetting().then((result)=>{
          console.log(result);
         });
```
异步调用 采用的是Codova提供的调用方式.

* 同步调用方式 
```javascript
var appinfo = ns.getAppInfoSync()
```
由于Codova不支持同步调用,所以通过其他方式解决.
```javascript NS.js
    NS.js
    /**
     * 自定义同步执行函数
     **/
    cordovaExecSync(pluginName, apiName, arr = []) {
        let isiOS = !!navigator.userAgent.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/);
        if (isiOS == true) {
            let command = "NSCordovaExecSync=" + JSON.stringify([pluginName, apiName, arr]);
            let result = prompt(command);
            if (typeof (result) == 'string') {
                return JSON.parse(result);
            }
            return result;
        }
        else {
            let result = jsSyncFunction.syncExec(pluginName, apiName, arr);
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
```
- (void)      webView:(WKWebView*)webView runJavaScriptTextInputPanelWithPrompt:(NSString*)prompt
          defaultText:(NSString*)defaultText initiatedByFrame:(WKFrameInfo*)frame
    completionHandler:(void (^)(NSString* result))completionHandler
{
    NSString * prefix=@"NSCordovaExecSync=";
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
在Codova初始化的时候 增加JavascriptInterface
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
        this.getWebview().addJavascriptInterface(syncExposedJsApi, "jsSyncFunction");
        this.cordovaInterface.onCordovaInit(this.appView.getPluginManager());
    }
```

### 客户端 调用H5提供的插件方法
首先H5先注册一个方法
```
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

```
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



