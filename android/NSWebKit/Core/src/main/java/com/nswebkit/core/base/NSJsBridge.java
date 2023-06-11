package com.nswebkit.core.base;

import org.apache.cordova.PluginManager;
import org.json.JSONException;

/**
 * 作者：Neil on 2023/5/23 11:58
 * <p>
 * www.github.com/guxiangyee/nswebkit.git
 * <p>
 * 作用： js与native同步接口Bridge
 */
public class NSJsBridge {

    private final PluginManager pluginManager;

    public NSJsBridge(PluginManager pluginManager) {
        this.pluginManager = pluginManager;
    }
    public String jsSyncExec(String service, String action, String arguments) throws JSONException {
        if(null != pluginManager.getPlugin(service)){
            return pluginManager.getPlugin(service).syncExecute(action,arguments);
        }
        return "发生异常，请检查API使用是否正确";
    }

}
