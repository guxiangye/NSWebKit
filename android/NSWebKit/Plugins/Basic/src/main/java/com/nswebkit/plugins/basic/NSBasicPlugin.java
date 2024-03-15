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
import androidx.core.content.FileProvider;

import com.google.gson.Gson;
import com.google.gson.internal.LinkedTreeMap;
import com.nswebkit.core.base.NSApplicationProvider;
import com.nswebkit.core.base.NSServiceProxy;
import com.nswebkit.core.browser.view.NSWebViewActivity;
import com.nswebkit.core.browser.view.NSWebViewFragment;
import com.nswebkit.core.utils.NSAppUtil;
import com.nswebkit.core.utils.NSImageUtil;
import com.nswebkit.core.utils.NSPreferenceUtil;
import com.nswebkit.core.utils.SerializableMap;
import com.nswebkit.plugins.basic.badge.BadgeIntentService;
import com.nswebkit.plugins.basic.watermark.NSWatermarkBean;
import com.nswebkit.plugins.basic.watermark.WatermarkUtil;
import com.nswebkit.plugins.basic.storage.NSStorage;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.engine.SystemWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

/**
 * @author Neil
 * @date 2023/5/30. description：基础插件
 */
public class NSBasicPlugin extends CordovaPlugin {

    private String requestArgs;
    private CallbackContext callbackContext;
    private JSONObject jsonObject;
    private JSONObject callbackObject;

    private final String kStorageDefaultGroup = "StorageDefaultGroup";
    public static String NSSchemeKey = "nsfile://";
    private final Gson gson = new Gson();

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
            try {
                jsonObject = (JSONObject) jsonArray.get(0);
            } catch (Exception e) {
                jsonObject = new JSONObject();
            }
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
        } else if ("openFile".equals(action)){
            String fileName = jsonObject.optString("fileName", kStorageDefaultGroup);
            String url = jsonObject.optString("url", kStorageDefaultGroup);
            new Thread(() -> {
                OkHttpClient client = new OkHttpClient();
                Request request = new Request.Builder().url(url).build();
                Response response = null;
                try {
                    response = client.newCall(request).execute();

                    if (!response.isSuccessful()) {
                        callbackObject.put("errCode", -1);
                        callbackObject.put("errorMsg", "下载失败");
                        callbackContext.error(callbackObject.toString());
                    }
                    InputStream inputStream = response.body().byteStream();
                    File file = new File(this.cordova.getActivity().getExternalFilesDir(null), fileName);

                    Uri fileUri = FileProvider.getUriForFile(this.cordova.getActivity(),
                            this.cordova.getActivity().getPackageName() + ".provider", file);
                    FileOutputStream outputStream = new FileOutputStream(file);
                    byte[] buffer = new byte[1024];
                    int len;
                    while ((len = inputStream.read(buffer)) != -1) {
                        outputStream.write(buffer, 0, len);
                    }
                    outputStream.close();
                    inputStream.close();

                    this.cordova.getActivity().runOnUiThread(() -> {
                        Intent intent = new Intent(Intent.ACTION_VIEW);
                        intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION|Intent.FLAG_ACTIVITY_CLEAR_TOP);
                        intent.setDataAndType(fileUri, this.webView.getResourceApi().getMimeType(fileUri));
                        this.cordova.getActivity().startActivity(intent);
                        callbackContext.success(callbackObject);
                    });
                } catch (Exception e) {
                    callbackContext.error(callbackObject.toString());
                }
            }).start();
            return true;
        } else if ("addWaterMark".equals(action)) {
            NSWatermarkBean data = gson.fromJson(jsonObject.toString(), NSWatermarkBean.class);
            WatermarkUtil.addWatermark(data, callbackContext, cordova);
            return true;
        } else if ("convertImagePathToBase64".equals(action)) {
            String path = jsonObject.optString("path", "");
            if (!TextUtils.isEmpty(path)) {
                JSONObject callbackObject = new JSONObject();
                callbackObject.put("errCode", 0);
                callbackObject.put("errorMsg", "success");
                callbackObject.put("base64Image", NSImageUtil.imageToBase64(path.replace(NSSchemeKey,"")));
                callbackContext.success(callbackObject);
                return true;
            } else {
                callbackObject.put("errCode", -1);
                callbackObject.put("errorMsg", "path不能为空");
                callbackContext.error(callbackObject.toString());
                return false;
            }
        } else if ("openNativePage".equals(action)) {
            Map paramsMap = new HashMap<>();
            String pageName = jsonObject.optString("pageName", "");
            JSONObject data = jsonObject.optJSONObject("extInfo");
            if (null != data) {
                paramsMap = gson.fromJson(data.toString(), HashMap.class);
            }
            if (!TextUtils.isEmpty(pageName)) {
                JSONObject callbackObject = new JSONObject();
                callbackObject.put("errCode", 0);
                callbackObject.put("errorMsg", "success");
                callbackContext.success(callbackObject);
                Intent intent = new Intent(action);
                if(null != paramsMap && paramsMap.size() > 0){
                    SerializableMap map = new SerializableMap();
                    map.setMap(paramsMap);
                    Bundle bundle = new Bundle();
                    bundle.putSerializable("paramsMap", map);
                    intent.putExtra("params", bundle);
                }
                this.cordova.getActivity().startActivity(intent);
                return true;
            } else {
                callbackObject.put("errCode", -1);
                callbackObject.put("errorMsg", "pageName不能为空");
                callbackContext.error(callbackObject.toString());
                return false;
            }
        } else if ("setStorage".equals(action)) {
            String groupName = jsonObject.optString("groupName", kStorageDefaultGroup);
            int validSecond = jsonObject.optInt("validSecond", 0);
            String key = jsonObject.optString("key", "");
            Object data = jsonObject.opt("data");
            if (!TextUtils.isEmpty(key)) {
                if (data instanceof JSONObject) {
                    JSONObject jsonObj = (JSONObject) data;
                    Map map = gson.fromJson(jsonObj.toString(), HashMap.class);
                    NSStorage.set(key, map, validSecond, groupName);
                } else {
                    NSStorage.set(key, data, validSecond, groupName);
                }
                callbackObject.put("errCode", 0);
                callbackObject.put("errorMsg", "success");
                callbackContext.success(callbackObject);
            } else {
                if (TextUtils.isEmpty(key)) {
                    callbackObject.put("errCode", -1);
                    callbackObject.put("errorMsg", "key 不能为空");
                    callbackContext.success(callbackObject);
                }
            }
            return true;
        } else if ("getStorage".equals(action)) {
            String groupName = jsonObject.optString("groupName", kStorageDefaultGroup);
            String key = jsonObject.optString("key", "");
            if (!TextUtils.isEmpty(key)) {
                Object data = NSStorage.get(key, groupName);
                if (data instanceof LinkedTreeMap) {
                    callbackObject.put("data", new JSONObject(gson.toJson(data)));
                } else {
                    callbackObject.put("data", data);
                }
                callbackObject.put("errCode", 0);
                callbackObject.put("errorMsg", "success");
                callbackContext.success(callbackObject);
            } else {
                if (TextUtils.isEmpty(key)) {
                    callbackObject.put("errCode", -1);
                    callbackObject.put("errorMsg", "key 不能为空");
                    callbackContext.success(callbackObject);
                }
            }
            return true;
        } else if ("removeStorage".equals(action)) {
            String groupName = jsonObject.optString("groupName", kStorageDefaultGroup);
            String key = jsonObject.optString("key", "");
            if (!TextUtils.isEmpty(key)) {
                NSStorage.remove(key, groupName);
                callbackObject.put("errCode", 0);
                callbackObject.put("errorMsg", "success");
                callbackContext.success(callbackObject);
            } else {
                callbackObject.put("errCode", -1);
                callbackObject.put("errorMsg", "key 不能为空");
                callbackContext.success(callbackObject);
            }
            return true;
        } else if ("clearStorage".equals(action)) {
            String groupName = jsonObject.optString("groupName", kStorageDefaultGroup);
            NSStorage.clear(groupName);
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
        JSONArray jsonArray = new JSONArray(arguments);
        if (jsonArray.length() > 0) {
            jsonObject = (JSONObject) jsonArray.get(0);
        } else {
            jsonObject = new JSONObject();
        }
        callbackObject = new JSONObject();
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
        } else if ("setStorageSync".equals(action)) {
            String key = jsonObject.optString("key", "");
            String groupName = jsonObject.optString("groupName", kStorageDefaultGroup);
            int validSecond = jsonObject.optInt("validSecond", 0);
            Object data = jsonObject.opt("data");
            if (!TextUtils.isEmpty(key)) {
                if (data instanceof JSONObject) {
                    JSONObject jsonObj = (JSONObject) data;
                    Map map = gson.fromJson(jsonObj.toString(), HashMap.class);
                    NSStorage.set(key, map, validSecond, groupName);
                } else {
                    NSStorage.set(key, data, validSecond, groupName);
                }
            }
            data = NSStorage.get(key, kStorageDefaultGroup);
            if (data instanceof LinkedTreeMap) {
                callbackObject.put("data", new JSONObject(gson.toJson(data)));

            } else {
                callbackObject.put("data", data);
            }
            return callbackObject.toString();
        } else if ("getStorageSync".equals(action)) {
            String key = jsonObject.optString("key", "");
            String groupName = jsonObject.optString("groupName", kStorageDefaultGroup);
            Object data = NSStorage.get(key, groupName);
            if (data instanceof LinkedTreeMap) {
                JSONObject result = new JSONObject(gson.toJson(data));
                callbackObject.put("data", result);

            } else {
                callbackObject.put("data", data);
            }
            return callbackObject.toString();
        } else if ("removeStorageSync".equals(action)) {
            String groupName = jsonObject.optString("groupName", kStorageDefaultGroup);
            String key = jsonObject.optString("key", "");
            if (!TextUtils.isEmpty(key)) {
                NSStorage.remove(key, groupName);
            }
            return callbackObject.toString();
        } else if ("clearStorageSync".equals(action)) {
            String groupName = jsonObject.optString("groupName", kStorageDefaultGroup);
            NSStorage.clear(groupName);
            return callbackObject.toString();
        }
        return "发生异常，请检查API使用是否正确";
    }

    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException {
        for (int r : grantResults) {
            if (r == PackageManager.PERMISSION_DENIED && null != this.callbackContext) {
                callbackObject.put("errCode", -1000);
                switch (requestCode) {
                    case 0://相机权限
                        boolean hideAlbum = jsonObject.optBoolean("hideAlbum", true);
                        callbackObject.put("errorMsg", "没有相机权限,请检查!");
                        break;
                    case 1:
                    case 2://
                        callbackObject.put("errorMsg", "没有读写权限,请检查!");
                        break;
                }
                callbackContext.success(callbackObject.toString());
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
