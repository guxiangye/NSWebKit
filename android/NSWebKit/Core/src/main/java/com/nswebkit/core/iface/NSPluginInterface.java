package com.nswebkit.core.iface;

import android.webkit.WebView;

import org.apache.cordova.CallbackContext;
import org.json.JSONException;

/**
 * 作者：Neil on 2023/5/31 19:23
 * <p>
 * www.github.com/guxiangyee/nswebkit.git
 * <p>
 * 作用： xxxx
 */
public interface NSPluginInterface {

    void theme(String theme);

    void onReceivedError(WebView view, int errorCode, String description, String failingUrl);

    void onReceivedTitle(WebView view, String title);
}
