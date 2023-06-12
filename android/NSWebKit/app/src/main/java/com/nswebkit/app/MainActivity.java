package com.nswebkit.app;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.nswebkit.core.base.NSApplicationProvider;
import com.nswebkit.core.base.NSInitInterface;
import com.nswebkit.core.base.NSServiceProxy;
import com.nswebkit.core.browser.view.NSWebViewActivity;

import java.util.Map;

public class MainActivity extends Activity {
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        NSApplicationProvider.getInstance().attachContext(this);

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
    }

    public void aaa(View view) {
        Intent intent = new Intent(this, NSWebViewActivity.class);
        intent.putExtra("url", "file:///android_asset/www/index.html");
        startActivity(intent);
    }
}
