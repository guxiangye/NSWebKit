package com.nswebkit.plugins.chooselocation;
import android.Manifest.permission;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.text.TextUtils;
import com.amap.api.location.AMapLocationClient;
import com.nswebkit.plugins.chooselocation.activity.NSMapLocationActivity;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PermissionHelper;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * @date 2022/11/3 on 13:57 @author: neil
 */
public class NSChooseLocationPlugin extends CordovaPlugin {

    private JSONObject callbackObject;
    private JSONObject jsonObject;
    private CallbackContext callbackContext;
    private final String[] locationPermissions = {permission.ACCESS_COARSE_LOCATION,
            permission.ACCESS_FINE_LOCATION, permission.ACCESS_LOCATION_EXTRA_COMMANDS};

    private  String types;//查询POI类型 详见:https://lbs.amap.com/api/webservice/guide/api/search;

    @Override
    public boolean execute(String action, String rawArgs, CallbackContext callbackContext)
            throws JSONException {
        this.callbackContext = callbackContext;
        callbackObject = new JSONObject();
        JSONArray jsonArray = new JSONArray(rawArgs);
        if (jsonArray.length() > 0) {
            jsonObject = (JSONObject) jsonArray.get(0);
        } else {
            jsonObject = new JSONObject();
        }

        boolean isLocationEnabled = isLocationEnabled();
        if ("chooseLocation".equals(action) && isLocationEnabled) {
            types = jsonObject.optString("types", "");
            if (!hasPermisssion(locationPermissions)) {
                requestPermissions(1, locationPermissions);
            } else {
                chooseLocation();
            }
            return true;
        } else {
            callbackObject.put("errCode", -2);
            if (isLocationEnabled) {
                callbackObject.put("errorMsg", "发生异常，请检查API使用是否正确");
            } else {
                callbackObject.put("errorMsg", "请开启GPS定位服务");
            }
            callbackContext.error(callbackObject.toString());
            return false;
        }

    }

    public boolean isLocationEnabled() {
        int locationMode = 0;
        String locationProviders;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            try {
                locationMode = Settings.Secure.getInt(
                        this.cordova.getContext().getContentResolver(),
                        Settings.Secure.LOCATION_MODE);
            } catch (Settings.SettingNotFoundException e) {
                e.printStackTrace();
                return false;
            }
            return locationMode != Settings.Secure.LOCATION_MODE_OFF;
        } else {
            locationProviders = Settings.Secure.getString(
                    this.cordova.getContext().getContentResolver(),
                    Settings.Secure.LOCATION_PROVIDERS_ALLOWED);
            return !TextUtils.isEmpty(locationProviders);
        }
    }

    public void chooseLocation()  {

        Intent intent = new Intent(this.cordova.getContext(),NSMapLocationActivity.class);
        intent.putExtra("types",types);
        this.cordova.startActivityForResult(this,intent,2);

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

    public void onRequestPermissionResult(int requestCode, String[] permissions,
                                          int[] grantResults) throws JSONException {
        PluginResult result;
        for (int r : grantResults) {
            if (r == PackageManager.PERMISSION_DENIED && null != this.callbackContext) {

                callbackObject.put("errCode", -1);
                callbackObject.put("errorMsg", "未获取到定位权限");
                this.callbackContext.success(callbackObject);
                return;
            }
        }

        if (requestCode == 1) {//定位
            chooseLocation();
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);
        System.out.println(intent.getExtras().getString("data"));

        try {
            callbackObject = new JSONObject(intent.getExtras().getString("data"));
            System.out.println(jsonObject);

            if (callbackObject != null) {
                callbackContext.success(callbackObject);
            }
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }
    }

    public void onRestoreStateForActivityResult(Bundle state, CallbackContext callbackContext) {
        this.callbackContext = callbackContext;
    }
}
