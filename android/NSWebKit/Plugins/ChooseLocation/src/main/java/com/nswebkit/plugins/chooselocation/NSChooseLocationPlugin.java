package com.nswebkit.plugins.chooselocation;
import static android.app.Activity.RESULT_OK;
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
import com.nswebkit.plugins.chooselocation.utils.NSMapLocationParam;
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


    @Override
    public boolean execute(String action, String rawArgs, CallbackContext callbackContext)
            throws JSONException {
        this.callbackContext = callbackContext;
        callbackObject = new JSONObject();
        JSONArray jsonArray = new JSONArray(rawArgs);
        if (jsonArray.length() > 0) {
            try {
                jsonObject = (JSONObject) jsonArray.get(0);
            }
            catch (Exception e){
                jsonObject = new JSONObject();
            }
        } else {
            jsonObject = new JSONObject();
        }


        if ("chooseLocation".equals(action) ) {
            String types = jsonObject.optString("types", "");
            int searchType = jsonObject.optInt("searchType",0);
            String city = jsonObject.optString("city","");
            boolean citylimit = jsonObject.optBoolean("citylimit",false);
            int radius = jsonObject.optInt("radius",0);
            NSMapLocationParam param = new NSMapLocationParam();
            param.types = types;
            param.searchType = searchType;
            param.city = city;
            param.cityLimit = citylimit;
            param.radius = radius;
            chooseLocation(param);
            return true;
        } else {
            callbackObject.put("errCode", -2);
            callbackObject.put("errorMsg", "发生异常，请检查API使用是否正确");
            callbackContext.error(callbackObject.toString());
            return false;
        }

    }



    public void chooseLocation( NSMapLocationParam param)  {

        Intent intent = new Intent(this.cordova.getContext(),NSMapLocationActivity.class);

        Bundle bundle = new Bundle();
        bundle.putSerializable("param",param);
        intent.putExtra("param",bundle);
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


    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);

        if (requestCode == 2 && resultCode == RESULT_OK){
            String data =  intent.getStringExtra("data");

            try {
                JSONObject callbackObject = new JSONObject(data);
                this.callbackContext.success(callbackObject);
            }
            catch (Exception e){


            }

        }
    }

    public void onRestoreStateForActivityResult(Bundle state, CallbackContext callbackContext) {
        this.callbackContext = callbackContext;
    }
}
