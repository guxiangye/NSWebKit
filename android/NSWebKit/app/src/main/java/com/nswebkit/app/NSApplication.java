package com.nswebkit.app;

import android.app.Application;
import android.content.Intent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.amap.api.location.AMapLocationClient;
import com.nswebkit.core.base.NSApplicationProvider;
import com.nswebkit.core.base.NSInitInterface;
import com.nswebkit.core.base.NSServiceProxy;
import com.nswebkit.core.browser.view.NSWebViewActivity;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class NSApplication extends Application {
    static NSApplication application;

    public static NSApplication getApplication() {
        return application;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        application = this;

        NSApplicationProvider.getInstance().attachContext(this);
        initSDKS();
    }

    public static void initSDKS() {
        // 高德地图定位
//        NSInitLocationSdk.getInstance().attachContext(NSApplication.getApplication());
        AMapLocationClient.updatePrivacyShow(NSApplication.getApplication(), true, true);
        AMapLocationClient.updatePrivacyAgree(NSApplication.getApplication(), true);

        NSServiceProxy.getInstance().setInitInterface(new NSInitInterface() {
            @NonNull
            @Override
            public String getDeviceId() {
                return "UN109922221";
            }

            @Override
            public String getImei() {
                return "0123456789";
            }

            @Override
            public String getAppId() {
                return "NS12346";
            }

            @Override
            public boolean isDev() {
                return true;
            }

            @Nullable
            @Override
            public Map getExtendInfo() {
                return null;
            }
        });

        // 分享
//        SPInitShareSdk.getInstance().attachContext(SPApplication.getApplication());
//        SPInitShareSdk.getInstance().registerWeChat(SPConfig.getInstance().wxAppid);
    }
}
