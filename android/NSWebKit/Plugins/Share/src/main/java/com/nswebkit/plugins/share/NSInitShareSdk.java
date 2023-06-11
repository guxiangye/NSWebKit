package com.nswebkit.plugins.share;

import android.app.Activity;
import android.app.Application;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

import org.apache.cordova.CallbackContext;

public class NSInitShareSdk {

    private static volatile NSInitShareSdk instance;

    public CallbackContext cordovaCallbackContext;
    private Application mContext;

    private IWXAPI api;

    public NSInitShareSdk() {
    }

    public void attachContext(Context context) {
        if (context != null) {
            this.mContext = context instanceof Activity ? ((Activity) context).getApplication()
                    : (Application) context.getApplicationContext();


        }
    }

    public void registerWeChat(String appid){
        // 通过 WXAPIFactory 工厂，获取 IWXAPI 的实例
        api = WXAPIFactory.createWXAPI(mContext, appid, true);

        // 将应用的 appId 注册到微信
        api.registerApp(appid);

        //建议动态监听微信启动广播进行注册到微信
        mContext.registerReceiver(new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {

                // 将该 app 注册到微信
                api.registerApp(appid);
            }
        }, new IntentFilter(ConstantsAPI.ACTION_REFRESH_WXAPP));

    }


    public static NSInitShareSdk getInstance() {
        if (instance == null) {
            Class var0 = NSInitShareSdk.class;
            synchronized (NSInitShareSdk.class) {
                if (instance == null) {
                    instance = new NSInitShareSdk();
                }
            }
        }

        return instance;
    }

    public Application getApplication() {
        return this.mContext;
    }

    public IWXAPI getWeChatApi() {
        return this.api;
    }
}
