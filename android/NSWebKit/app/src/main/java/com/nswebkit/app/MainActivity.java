package com.nswebkit.app;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import androidx.annotation.Nullable;
import com.nswebkit.core.browser.view.NSWebViewActivity;

public class MainActivity extends NSWebViewActivity {
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        getIntent().putExtra("url", "file:///android_asset/www/index.html");
        super.onCreate(savedInstanceState);
        //setContentView(R.layout.activity_main);
    }

    public void aaa(View view) {
        Intent intent = new Intent(this, NSWebViewActivity.class);
        intent.putExtra("url", "file:///android_asset/www/index.html");
        startActivity(intent);
    }
}
