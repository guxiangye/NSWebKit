package com.nswebkit.plugins.basic;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.nswebkit.core.base.NSApplicationProvider;
import com.nswebkit.core.base.NSServiceProxy;
import com.nswebkit.core.browser.view.NSWebViewActivity;
import com.nswebkit.core.browser.view.NSWebViewFragment;
import com.nswebkit.core.utils.NSAppUtil;
import com.nswebkit.core.utils.NSPreferenceUtil;
import com.nswebkit.plugins.basic.badge.BadgeIntentService;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.cordova.engine.SystemWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

/**
 * @author Neil
 * @date 2023/5/30. description：基础插件
 */
public class NSBasicPlugin extends CordovaPlugin {

    private String requestArgs;
    private CallbackContext callbackContext;
    private JSONObject jsonObject;
    private JSONObject callbackObject;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        return super.execute(action, args, callbackContext);
    }

    @Override
    public boolean execute(String action, String rawArgs, CallbackContext callbackContext) throws JSONException {
        System.out.println(this.cordova);
        System.out.println(this.cordova.getActivity());
        System.out.println(this.webView);

        this.callbackContext = callbackContext;
        this.requestArgs = rawArgs;
        JSONArray jsonArray = new JSONArray(rawArgs);
        if (jsonArray.length() > 0) {
            jsonObject = (JSONObject) jsonArray.get(0);
        } else {
            jsonObject = new JSONObject();
        }
        callbackObject = new JSONObject();
        if ("navigateTo".equals(action)) {
            String url = jsonObject.optString("url", "");

            Intent intent = new Intent(this.cordova.getActivity(), NSWebViewActivity.class);
            intent.putExtra("url", url);
            intent.putExtra("theme", jsonObject.toString());
            // 新打开一个界面返回按钮一定显示
            intent.putExtra("showBackBtn", true);
            this.cordova.getActivity().startActivity(intent);
            callbackObject.put("errCode", 0);
            callbackObject.put("errorMsg", "success");
            callbackContext.success(callbackObject);
            return true;
        } else if ("navigateBack".equals(action)) {
            this.cordova.getActivity().finish();
            callbackObject.put("errCode", 0);
            callbackObject.put("errorMsg", "success");
            callbackContext.success(callbackObject);
            return true;
        } else if ("openExternalBrowser".equals(action)) {
            String url = jsonObject.optString("url", "");
            if (TextUtils.isEmpty(url)) {
                callbackObject.put("errCode", -1);
                callbackObject.put("errorMsg", "url为空");
                callbackContext.error(callbackObject.toString());
                return false;
            } else {
                Uri uri = Uri.parse(url);
                Intent intent = new Intent(Intent.ACTION_VIEW, uri);
                this.cordova.getActivity().startActivity(intent);
                callbackObject.put("errCode", 0);
                callbackObject.put("errorMsg", "success");
                callbackContext.success(callbackObject);
                return true;
            }
        } else if ("makePhoneCall".equals(action)) {
            String mobile = jsonObject.optString("phoneNumber", "");
            if (TextUtils.isEmpty(mobile)) {
                callbackObject.put("errCode", -1);
                callbackObject.put("errorMsg", "电话号码为空");
                callbackContext.error(callbackObject.toString());
                return false;
            } else {
                Intent intent = new Intent(Intent.ACTION_DIAL, Uri.parse("tel:" + mobile));
                this.cordova.getActivity().startActivity(intent);
                callbackObject.put("errCode", 0);
                callbackObject.put("errorMsg", "success");
                callbackContext.success(callbackObject);
                return true;
            }
        } else if ("openAppAuthorizeSetting".equals(action)) {
            Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).setData(Uri.fromParts("package", this.cordova.getActivity().getPackageName(), null));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            this.cordova.getActivity().startActivity(intent);
            callbackObject.put("errCode", 0);
            callbackObject.put("errorMsg", "success");
            callbackContext.success(callbackObject);
            return true;
        } else if ("setNavigationBarTheme".equals(action)) {
            NSWebViewActivity activity = (NSWebViewActivity) this.cordova.getActivity();
            NSWebViewFragment fragment = null;
            try {
                fragment = activity.getFragment();
            } catch (Exception e) {
                Log.e("SetNavigationBarTheme", e.getLocalizedMessage());
            }
            if (fragment != null) {
                fragment.theme(jsonObject.toString());
                callbackObject.put("errCode", 0);
                callbackObject.put("errorMsg", "success");
                callbackContext.success(callbackObject);
                return true;
            } else {
                callbackObject.put("errCode", -1);
                callbackObject.put("errorMsg", "basic plugin error!");
                callbackContext.error(callbackObject);
                return false;
            }
        } else if ("setClipboardData".equals(action)) {
            String data = jsonObject.optString("data", "");
            if (TextUtils.isEmpty(data)) {
                callbackObject.put("errCode", -1);
                callbackObject.put("errorMsg", "内容为空");
                callbackContext.error(callbackObject.toString());
                return false;
            } else {
                try {
                    ClipboardManager cm = (ClipboardManager) this.cordova.getActivity().getSystemService(Context.CLIPBOARD_SERVICE);
                    ClipData mClipData = ClipData.newPlainText("Label", data);
                    cm.setPrimaryClip(mClipData);
                } catch (Exception e) {
                    Log.e("WebView-Clipboard", e.getLocalizedMessage());
                }
                callbackObject.put("errCode", 0);
                callbackObject.put("errorMsg", "success");
                callbackContext.success(callbackObject);
                return true;
            }
        } else if ("setBadgeCount".equals(action)) {
            int count = jsonObject.optInt("count", -1);
            this.cordova.getActivity().startService(new Intent(this.cordova.getActivity(), BadgeIntentService.class).putExtra("badgeCount", count));
            callbackObject.put("errCode", 0);
            callbackObject.put("errorMsg", "success");
            callbackContext.success(callbackObject);
            return true;
        } else if ("setEnableDebug".equals(action)) {
            boolean enableDebug = jsonObject.optBoolean("enableDebug", false);
            this.cordova.getActivity().runOnUiThread(() -> {
                ((SystemWebView)this.webView.getView()).setWebContentsDebuggingEnabled(true);
            });
            callbackObject.put("errCode", 0);
            callbackObject.put("errorMsg", "success");
            callbackContext.success(callbackObject);
            return true;
        } else if ("getNotificationSwitchStatus".equals(action)) {
            callbackObject.put("errCode", 0);
            callbackObject.put("errorMsg", "success");
            callbackObject.put("status", NSAppUtil.isNotifyEnabled(cordova.getContext()));
            callbackContext.success(callbackObject);
            return true;
        } else if ("cleanWebviewCache".equals(action)) {
            ((SystemWebView)this.webView.getView()).clearCache(true);
            callbackObject.put("errCode", 0);
            callbackObject.put("errorMsg", "success");
            callbackContext.success(callbackObject);
            return true;
        } else if ("toast".equals(action)) {
            String msg = jsonObject.optString("msg", "");
            Toast.makeText(cordova.getContext(), msg, Toast.LENGTH_SHORT).show();
            return true;
        } else if ("getVoiceBroadcastSwitchStatus".equals(action)) {
            callbackObject.put("errCode", 0);
            callbackObject.put("errorMsg", "success");
            callbackObject.put("status", NSPreferenceUtil.getBooleanValue(cordova.getContext(), "VoiceSwitchStatus", false));
            callbackContext.success(callbackObject);
            return true;
        } else if ("setVoiceBroadcastSwitchStatus".equals(action)) {
            boolean status = jsonObject.optBoolean("status", false);
            NSPreferenceUtil.setBooleanValue(cordova.getContext(), "VoiceSwitchStatus", status);
            callbackObject.put("errCode", 0);
            callbackObject.put("errorMsg", "success");
            callbackContext.success(callbackObject);
            return true;
        } else {
            callbackObject.put("errCode", -2);
            callbackObject.put("errorMsg", "发生异常，请检查API使用是否正确");
            callbackContext.error(callbackObject.toString());
            return false;
        }
    }

    public String syncExecute(String action, String arguments) throws JSONException {
        if ("getAppInfoSync".equals(action)) {
            JSONObject appInfo = new JSONObject();
            appInfo.put("appId", NSServiceProxy.getInstance().getInitInterface().getAppId());
            appInfo.put("appVersionCode", NSAppUtil.getAppVersionCode());
            appInfo.put("appVersionName", NSAppUtil.getAppVersionName());

            Map extendInfo = NSServiceProxy.getInstance().getInitInterface().getExtendInfo();
            if(extendInfo != null){
                appInfo.put("extendInfo", new JSONObject(extendInfo));
            }

            return appInfo.toString();
        } else if ("getDeviceInfoSync".equals(action)) {
            JSONObject deviceObject = new JSONObject();
            deviceObject.put("osType", 1);
            deviceObject.put("osVersion", Build.VERSION.RELEASE);
            deviceObject.put("deviceId", NSServiceProxy.getInstance().getInitInterface().getDeviceId());
            deviceObject.put("model", Build.MODEL);
            deviceObject.put("brand", Build.BRAND);
            deviceObject.put("os", NSAppUtil.isHarmonyOS() ? "Harmony" : "Android");
            deviceObject.put("imei", NSServiceProxy.getInstance().getInitInterface().getImei());
            deviceObject.put("statusBarHeight", NSAppUtil.getStatusBarHeight(NSApplicationProvider.getInstance().getApplication()));
            return deviceObject.toString();
        } else if ("getClipboardDataSync".equals(action)) {
            ClipboardManager clipboard = (ClipboardManager) this.cordova.getActivity().getSystemService(Context.CLIPBOARD_SERVICE);
            ClipData clipData = clipboard.getPrimaryClip();
            if (clipData != null && clipData.getItemCount() > 0) {
                CharSequence text = clipData.getItemAt(0).getText();
                return text.toString();
            }
            return "";
        }
        return "发生异常，请检查API使用是否正确";
    }

    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException {
        PluginResult result;
        for (int r : grantResults) {
            if (r == PackageManager.PERMISSION_DENIED && null != this.callbackContext) {
                result = new PluginResult(PluginResult.Status.ILLEGAL_ACCESS_EXCEPTION);
                this.callbackContext.sendPluginResult(result);
                return;
            }
        }
    }

    public void onRestoreStateForActivityResult(Bundle state, CallbackContext callbackContext) {
        this.callbackContext = callbackContext;
    }

    /**
     * 检查是否获取所有权限
     */
    private boolean checkPermissionAllGranted(String[] permissions) {
        for (String permission : permissions) {
            if (ContextCompat.checkSelfPermission(cordova.getContext(), permission) != PackageManager.PERMISSION_GRANTED) {
                // 只要有一个权限没有被授予, 则直接返回 false
                return false;
            }
        }
        return true;
    }

    /**
     * 检查是否有勾选了对话框中”Don’t ask again”的选项
     */
    private boolean shouldShowRequestPermissionRationale(String[] permissions) {
        for (String permission : permissions) {
            // 勾选了对话框中”Don’t ask again”的选项, 返回false
            if (!ActivityCompat.shouldShowRequestPermissionRationale(cordova.getActivity(), permission)) {
                // 只要有一个权限没有被授予, 则直接返回 false
                return false;
            }
        }
        return true;
    }
}
