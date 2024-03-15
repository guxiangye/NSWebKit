package com.nswebkit.plugins.scan;

import android.Manifest.permission;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.text.TextUtils;
import android.widget.Toast;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import com.nswebkit.plugins.scan.scan.MNScanManager;
import com.nswebkit.plugins.scan.scan.model.MNScanConfig;
import com.nswebkit.plugins.scan.scan.other.MNScanCallback;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PermissionHelper;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * @author Neil
 * @date 2023/5/30. description：基础插件
 */
public class NSScanPlugin extends CordovaPlugin {

    private String[] scanPermissions = {permission.CAMERA};
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
        this.callbackContext = callbackContext;
        this.requestArgs = rawArgs;
        JSONArray jsonArray = new JSONArray(rawArgs);
        if (jsonArray.length() > 0) {
            jsonObject = (JSONObject) jsonArray.get(0);
        } else {
            jsonObject = new JSONObject();
        }
        callbackObject = new JSONObject();
        if ("scanCode".equals(action)) {
            if (!hasPermisssion(scanPermissions)) {
                requestPermissions(0, scanPermissions);
            } else {
                boolean hideAlbum = jsonObject.optBoolean("hideAlbum", true);
                int type = getScanType();
                scan(hideAlbum, type, callbackContext);
            }
            return true;
        } else {
            callbackObject.put("errCode", -2);
            callbackObject.put("errorMsg", "发生异常，请检查API使用是否正确");
            callbackContext.error(callbackObject.toString());
            return false;
        }
    }

    private int getScanType() {
        String scanType = jsonObject.optString("scanType");
        int type = 0;
        if (scanType.contains("qrCode") && !scanType.contains("barCode")) {
            type = 1;
        } else if (scanType.contains("barCode") && !scanType.contains("qrCode")) {
            type = 2;
        }
        return type;
    }

    public String syncExecute(String action, String arguments) throws JSONException {
        return null;
    }

    public void scan(boolean hideAlbum, int scanType, CallbackContext callbackContext) {
        Activity activity = this.cordova.getActivity();
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                MNScanConfig scanConfig = new MNScanConfig.Builder()
                        // 设置完成震动
                        .isShowVibrate(true)
                        // 扫描完成声音
                        .isShowBeep(true)
                        // 显示相册功能
                        .isShowPhotoAlbum(!hideAlbum)
                        // 显示闪光灯
                        .isShowLightController(true)
                        // 扫描线的颜色
                        .setScanColor("#22CE6B")
                        // 是否支持手势缩放
                        .setSupportZoom(true)
                        // 是否显示缩放控制器
                        .isShowZoomController(true)
                        // 显示缩放控制器位置
                        .setZoomControllerLocation(MNScanConfig.ZoomControllerLocation.Right)
                        // 扫描线样式
                        .setLaserStyle(MNScanConfig.LaserStyle.Line)
                        // 背景颜色
                        .setBgColor("#22FF0000")
                        // 是否全屏扫描,默认只扫描扫描框内的二维码
                        .setFullScreenScan(true)
                        // 二维码标记点
                        .isShowResultPoint(true)
                        // 是否支持多二维码同时扫出,默认false,多二维码状态不支持条形码
                        .setSupportMultiQRCode(false)
                        // 自定义遮罩
                        .setCustomShadeViewLayoutID(0, null).setSupportCode(scanType).builder();
                MNScanManager.startScan(activity, scanConfig, new MNScanCallback() {
                    @Override
                    public void onActivityResult(int resultCode, Intent data) {
                        JSONObject callbackObject = new JSONObject();
                        switch (resultCode) {
                            case MNScanManager.RESULT_SUCCESS:
                                String resultSuccess = data.getStringExtra(MNScanManager.INTENT_KEY_RESULT_SUCCESS);
                                String resultType = data.getStringExtra(MNScanManager.INTENT_KEY_RESULT_TYPE);
                                try {
                                    callbackObject.put("errCode", 0);
                                    callbackObject.put("errorMsg", "success");
                                    callbackObject.put("code", resultSuccess);
                                    if (!TextUtils.isEmpty(resultType)) {
                                        if (resultType.equals("QR_CODE")) {
                                            resultType = "qrCode";
                                        } else {
                                            resultType = "barCode";
                                        }
                                    }
                                    callbackObject.put("scanType", resultType);
                                    callbackContext.success(callbackObject);
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                                break;
                            case MNScanManager.RESULT_FAIL:
                                String resultError = data.getStringExtra(MNScanManager.INTENT_KEY_RESULT_ERROR);
                                try {
                                    callbackObject.put("errCode", -1);
                                    callbackObject.put("errorMsg", resultError);
                                    callbackContext.success(callbackObject);
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                                callbackContext.success(resultError);
                                break;
                            case MNScanManager.RESULT_CANCLE:
                                try {
                                    callbackObject.put("errCode", -2);
                                    callbackObject.put("errorMsg", "扫码关闭");
                                    callbackContext.error("Unexpected error");
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                                break;
                        }
                    }
                });
            }
        });
    }

    /**
     * check application's permissions
     */
    public boolean hasPermisssion(String[] permissions) {
        for (String p : permissions) {
            if (!PermissionHelper.hasPermission(this, p)) {
                return false;
            }
        }
        return true;
    }

    public void requestPermissions(int requestCode, String[] permissions) {
        PermissionHelper.requestPermissions(this, requestCode, permissions);
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

        switch (requestCode) {
            case 0://扫码
                boolean hideAlbum = jsonObject.optBoolean("hideAlbum", true);
                int type = getScanType();
                scan(hideAlbum, type, callbackContext);
                break;
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
