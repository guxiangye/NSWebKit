package com.nswebkit.core.iface;

import android.webkit.JavascriptInterface;

import com.nswebkit.core.base.NSJsBridge;

import org.json.JSONException;

/**
 * 作者：Neil on 2023/5/23 09:22
 * <p>
 * www.github.com/guxiangyee/nswebkit.git
 * <p>
 * 作用： js同步调用native
 */
public class NSSyncExposedJsApi {

    private final NSJsBridge bridge;

    public NSSyncExposedJsApi(NSJsBridge bridge) {
        this.bridge = bridge;
    }

    @JavascriptInterface
    public String syncExec(String service, String action,String arguments)throws JSONException {
        return bridge.jsSyncExec(service,action,arguments);
    }

}
