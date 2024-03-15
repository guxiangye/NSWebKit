package com.nswebkit.plugins.location;

import static android.content.Context.LOCATION_SERVICE;

import android.Manifest.permission;
import android.annotation.SuppressLint;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;

import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationListener;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PermissionHelper;
import org.apache.cordova.PluginResult;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * 作者：Neil on 2023/6/6 10:28
 */
public class NSLocationPlugin extends CordovaPlugin {

    private JSONObject callbackObject;
    private LocationManager locationManager;
    private CallbackContext callbackContext;
    //声明AMapLocationClient类对象
    private AMapLocationClient mLocationClient = null;
    private final String[] locationPermissions = {permission.ACCESS_COARSE_LOCATION,
            permission.ACCESS_FINE_LOCATION, permission.ACCESS_LOCATION_EXTRA_COMMANDS};

    @Override
    public boolean execute(String action, String rawArgs, CallbackContext callbackContext)
            throws JSONException {
        this.callbackContext = callbackContext;
        callbackObject = new JSONObject();
        boolean isLocationEnabled = isLocationEnabled();
        if ("getLocationInfo".equals(action) && isLocationEnabled) {
            if (!hasPermisssion(locationPermissions)) {
                requestPermissions(1, locationPermissions);
            } else {
                getLocationInfo();
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

    @SuppressLint("MissingPermission")
    public void getLocationInfo() throws JSONException {
        try {
            ApplicationInfo appInfo = this.cordova.getContext().getPackageManager().getApplicationInfo(this.cordova.getContext().getPackageName(), PackageManager.GET_META_DATA);
            String apikey = appInfo.metaData == null ? "" : appInfo.metaData.getString("com.amap.api.v2.apikey");
            if (TextUtils.isEmpty(apikey)) {
                //检查Manifest.xml里是否集成高德地图的key,如果没有仅获取经纬度

                locationManager = (LocationManager) this.cordova.getContext()
                        .getSystemService(LOCATION_SERVICE);
                if (locationManager == null) {
                    callbackObject.put("errCode", -1);
                    callbackObject.put("errorMsg", "发生未知错误,locationManager 为空");
                    this.callbackContext.success(callbackObject);
                    return;
                }
                locationManager
                        .requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 1000, 10, mSystemLocationListener);
                locationManager
                        .requestLocationUpdates(LocationManager.GPS_PROVIDER, 1000, 10, mSystemLocationListener);
            } else {
                //通过高德定位SDK
                if (null == mLocationClient) {
                    //初始化定位
                    try {
                        mLocationClient = new AMapLocationClient(
                                this.cordova.getContext());
                        //设置定位回调监听
                        mLocationClient.setLocationListener(mLocationListener);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                if (null != mLocationClient) {
                    mLocationClient.startLocation();
                } else {
                    callbackObject.put("errCode", -2);
                    callbackObject.put("errorMsg", "发生异常，请检查是否更新隐私合规");
                    callbackContext.error(callbackObject.toString());
                }
            }
        } catch (PackageManager.NameNotFoundException e) {

        }
    }

    private final LocationListener mSystemLocationListener = new LocationListener() {

        // Provider的状态在可用、暂时不可用和无服务三个状态直接切换时触发此函数
        @Override
        public void onStatusChanged(String provider, int status, Bundle extras) {
//      Log.d(TAG, "onStatusChanged");
        }

        // Provider被enable时触发此函数，比如GPS被打开
        @Override
        public void onProviderEnabled(String provider) {
//      Log.d(TAG, "onProviderEnabled");
        }

        // Provider被disable时触发此函数，比如GPS被关闭
        @Override
        public void onProviderDisabled(String provider) {
//      Log.d(TAG, "onProviderDisabled");
        }

        //当坐标改变时触发此函数，如果Provider传进相同的坐标，它就不会被触发
        @Override
        public void onLocationChanged(Location location) {

            Log.d("TAG", String.format("location: longitude: %f, latitude: %f", location.getLongitude(),
                    location.getLatitude()));
            if (callbackContext != null) {
                try {
                    callbackObject.put("errCode", 0);
                    callbackObject.put("latitude", location.getLatitude());
                    callbackObject.put("longitude", location.getLongitude());
                    callbackContext.success(callbackObject);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                callbackObject = null;
            }
            //更新位置信息
            locationManager.removeUpdates(this);
        }
    };


    //声明定位回调监听器
    private final AMapLocationListener mLocationListener = aMapLocation -> {
        try {
            callbackObject.put("errCode", 0);
            callbackObject.put("city", aMapLocation.getCity());
            callbackObject.put("country", aMapLocation.getCountry());
            callbackObject.put("district", aMapLocation.getDistrict());
            callbackObject.put("formattedAddress", aMapLocation.getAddress());
            callbackObject.put("latitude", aMapLocation.getLatitude());
            callbackObject.put("longitude", aMapLocation.getLongitude());
            callbackObject.put("province", aMapLocation.getProvince());
            callbackObject.put("street", aMapLocation.getStreet());
            callbackObject.put("number", aMapLocation.getStreetNum());
            callbackContext.success(callbackObject);
            mLocationClient.stopLocation();
        } catch (JSONException e) {
            e.printStackTrace();
        }
    };

    /**
     * check application's permissions
     */
    public boolean hasPermisssion() {
        for (String p : locationPermissions) {
            if (!PermissionHelper.hasPermission(this, p)) {
                return false;
            }
        }
        return true;
    }

    public boolean hasPermisssion(String[] permissions) {
        for (String p : permissions) {
            if (!PermissionHelper.hasPermission(this, p)) {
                return false;
            }
        }
        return true;
    }

    public void requestPermissions(int requestCode) {
        PermissionHelper.requestPermissions(this, requestCode, locationPermissions);
    }

    public void requestPermissions(int requestCode, String[] permissions) {
        PermissionHelper.requestPermissions(this, requestCode, permissions);
    }

    public void onRequestPermissionResult(int requestCode, String[] permissions,
                                          int[] grantResults) throws JSONException {
        PluginResult result;
        for (int r : grantResults) {
            if (r == PackageManager.PERMISSION_DENIED && null != this.callbackContext) {

                callbackObject.put("errCode", -1000);
                callbackObject.put("errorMsg", "未获取到定位权限，请检查!");
                this.callbackContext.success(callbackObject);
                return;
            }
        }

        if (requestCode == 1) {//定位
            getLocationInfo();
        }
    }

    public void onRestoreStateForActivityResult(Bundle state, CallbackContext callbackContext) {
        this.callbackContext = callbackContext;
    }
}
