package com.nswebkit.plugins.basic.watermark;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.text.TextUtils;

import com.luck.lib.camerax.utils.DateUtils;
import com.nswebkit.core.utils.NSImageUtil;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;

public class WatermarkUtil {
    public static String NSSchemeKey = "nsfile://";

    public static void addWatermark(NSWatermarkBean data, CallbackContext callbackContext, CordovaInterface cordova) throws JSONException {
        Bitmap sourBitmap = null;
        if (TextUtils.isEmpty(data.getImagePath())) {
            sourBitmap = NSImageUtil.convertBase64ToPic(data.getBase64Image());
        } else if (!TextUtils.isEmpty(data.getImagePath())) {
            String path = data.getImagePath();
            if (path.startsWith(NSSchemeKey)) {
                sourBitmap = BitmapFactory.decodeFile(data.getImagePath().replace(NSSchemeKey, ""));
            } else {
                sourBitmap = WatermarkUtil.getBitmap(path);
            }
        }

        sourBitmap = sourBitmap.copy(Bitmap.Config.ARGB_8888, true);
        NSWatermarkView watermarkView = new NSWatermarkView(cordova.getContext());
        watermarkView.setData(data,sourBitmap);
        Bitmap waterBitmap = NSImageUtil.convertViewToBitmap(watermarkView);
        Bitmap watermarkBitmap = null;
        if (null != data.getPosition()) {
            switch (data.getPosition()) {
                case 0:
                    watermarkBitmap = NSImageUtil.createWaterMaskLeftTop(cordova.getContext(), sourBitmap, waterBitmap, 0, 0);
                    break;
                case 1:
                    watermarkBitmap = NSImageUtil.createWaterMaskRightTop(cordova.getContext(), sourBitmap, waterBitmap, 0, 0);
                    break;
                case 2:
                    watermarkBitmap = NSImageUtil.createWaterMaskLeftBottom(cordova.getContext(), sourBitmap, waterBitmap, 0, 0);
                    break;
                case 3:
                    watermarkBitmap = NSImageUtil.createWaterMaskRightBottom(cordova.getContext(), sourBitmap, waterBitmap, 0, 0);
                    break;
                case 4:
                    watermarkBitmap = NSImageUtil.createWaterMaskCenter(sourBitmap, waterBitmap);
                    break;
            }
        } else {
            watermarkBitmap = NSImageUtil.createWaterMaskRightBottom(cordova.getContext(), sourBitmap, waterBitmap, 0, 0);
        }
        try {
            File targetFile = new File(getSandboxMarkDir(cordova), DateUtils.getCreateFileName("Mark_") + ".jpg");
            FileOutputStream outputStream = new FileOutputStream(targetFile);
            watermarkBitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);
            outputStream.close();
            JSONObject callbackObject = new JSONObject();
            callbackObject.put("errCode", 0);
            callbackObject.put("errorMsg", "success");
            callbackObject.put("base64Image", NSImageUtil.imageToBase64(targetFile.getPath()));
            callbackObject.put("path", NSSchemeKey + targetFile.getPath());
            callbackContext.success(callbackObject);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static String getSandboxMarkDir(CordovaInterface cordova) {
        File externalFilesDir = cordova.getContext().getExternalFilesDir("");
        File customFile = new File(externalFilesDir.getAbsolutePath(), "Mark");
        if (!customFile.exists()) {
            customFile.mkdirs();
        }
        return customFile.getAbsolutePath() + File.separator;
    }

    public static Bitmap returnBitMap(final String url){
        final Bitmap[] bitmap = new Bitmap[1];
        new Thread(new Runnable() {
            @Override
            public void run() {
                URL imageUrl = null;
                try {
                    imageUrl = new URL(url);
                    HttpURLConnection conn = (HttpURLConnection)imageUrl.openConnection();
                    conn.setDoInput(true);
                    conn.connect();
                    InputStream is = conn.getInputStream();
                    bitmap[0] = BitmapFactory.decodeStream(is);
                    is.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }).start();
        return bitmap[0];
    }

    public static Bitmap getBitmap(String url) {
        Bitmap bm = null;
        try {
            URL iconUrl = new URL(url);
            URLConnection conn = iconUrl.openConnection();
            HttpURLConnection http = (HttpURLConnection) conn;

            int length = http.getContentLength();

            conn.connect();
            // 获得图像的字符流
            InputStream is = conn.getInputStream();
            BufferedInputStream bis = new BufferedInputStream(is, length);
            bm = BitmapFactory.decodeStream(bis);
            bis.close();
            is.close();// 关闭流
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return bm;
    }
}
