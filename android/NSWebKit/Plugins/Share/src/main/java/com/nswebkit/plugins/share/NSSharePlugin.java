package com.nswebkit.plugins.share;


import android.util.Base64;

import com.nswebkit.plugins.share.NSInitShareSdk;
import com.tencent.mm.opensdk.modelbiz.WXLaunchMiniProgram;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX;
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage;
import com.tencent.mm.opensdk.modelmsg.WXMiniProgramObject;
import com.tencent.mm.opensdk.openapi.IWXAPI;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class NSSharePlugin extends CordovaPlugin {

    private CallbackContext callbackContext;

    private JSONObject jsonObject;
    private JSONObject callbackObject;


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
        callbackObject = new JSONObject();


        if ("sendWXAuthRequest".equals(action)) {
            //微信授权
            SendAuth.Req req = new SendAuth.Req();
            req.scope = "snsapi_userinfo";
            IWXAPI api = NSInitShareSdk.getInstance().getWeChatApi();
            api.sendReq(req);
            NSInitShareSdk.getInstance().cordovaCallbackContext = callbackContext;

            return true;
        } else if ("launchWXMiniProgram".equals(action)) {
            //打开小程序
            String userName = jsonObject.optString("userName", "");
            String path = jsonObject.optString("path", "");
            String miniProgramType = jsonObject.optString("miniProgramType", "");
            int _miniProgramType = 0;
            if ("WXMiniProgramTypeTest".equals(miniProgramType)) {
                _miniProgramType = 1;
            } else if ("WXMiniProgramTypePreview".equals(miniProgramType)) {
                _miniProgramType = 2;
            }
            IWXAPI api = NSInitShareSdk.getInstance().getWeChatApi();
            WXLaunchMiniProgram.Req req = new WXLaunchMiniProgram.Req();
            req.userName = userName; // 填小程序原始id
            req.path = path;                  ////拉起小程序页面的可带参路径，不填默认拉起小程序首页，对于小游戏，可以只传入 query 部分，来实现传参效果，如：传入 "?foo=bar"。
            req.miniprogramType = _miniProgramType;
            api.sendReq(req);

            NSInitShareSdk.getInstance().cordovaCallbackContext = callbackContext;

            return true;
        } else if ("shareToWXMiniProgram".equals(action)) {
            //分享小程序
            String title = jsonObject.optString("title", "");
            String userName = jsonObject.optString("userName", "");
            String path = jsonObject.optString("path", "");
            String hdImageData =jsonObject.optString("hdImageData", "");



            String webpageUrl =jsonObject.optString("webpageUrl", "");
            String descript =jsonObject.optString("descript", "");
            boolean  withShareTicket =jsonObject.optBoolean("descript", false);
            String miniProgramType = jsonObject.optString("miniProgramType", "");
            int _miniProgramType = 0;
            if ("WXMiniProgramTypeTest".equals(miniProgramType)) {
                _miniProgramType = 1;
            } else if ("WXMiniProgramTypePreview".equals(miniProgramType)) {
                _miniProgramType = 2;
            }

            IWXAPI api = NSInitShareSdk.getInstance().getWeChatApi();
            WXMiniProgramObject miniProgramObj = new WXMiniProgramObject();
            miniProgramObj.webpageUrl = webpageUrl; // 兼容低版本的网页链接
            miniProgramObj.miniprogramType = _miniProgramType;// 正式版:0，测试版:1，体验版:2
            miniProgramObj.userName = userName;     // 小程序原始id
            miniProgramObj.path = path;            //小程序页面路径；对于小游戏，可以只传入 query 部分，来实现传参效果，如：传入 "?foo=bar"
            WXMediaMessage msg = new WXMediaMessage(miniProgramObj);
            msg.title = title;                    // 小程序消息title
            msg.description = descript;               // 小程序消息desc
            if (hdImageData.contains(",")) {
                hdImageData = hdImageData.split(",")[1];
            }
            byte[] decode = Base64.decode(hdImageData, Base64.DEFAULT);
            msg.thumbData = decode;                      // 小程序消息封面图片，小于128k

            SendMessageToWX.Req req = new SendMessageToWX.Req();
            req.transaction = "miniProgram" + System.currentTimeMillis();
            req.message = msg;
            req.scene = SendMessageToWX.Req.WXSceneSession;  // 目前只支持会话
            api.sendReq(req);


            NSInitShareSdk.getInstance().cordovaCallbackContext = callbackContext;

            return true;

        } else {
            callbackObject.put("errCode", -2);

            callbackContext.error(callbackObject.toString());
            return false;
        }

    }

}