package com.nswebkit.plugins.customcamera;

import java.io.File;
import java.util.ArrayList;
import android.Manifest.permission;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PermissionHelper;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import top.zibin.luban.CompressionPredicate;
import top.zibin.luban.Luban;
import top.zibin.luban.OnNewCompressListener;
import top.zibin.luban.OnRenameListener;

import com.luck.picture.lib.basic.PictureSelector;
import com.luck.picture.lib.config.PictureMimeType;
import com.luck.picture.lib.config.SelectMimeType;
import com.luck.picture.lib.engine.CompressFileEngine;
import com.luck.picture.lib.entity.LocalMedia;
import com.luck.picture.lib.entity.MediaExtraInfo;
import com.luck.picture.lib.interfaces.OnKeyValueResultCallbackListener;
import com.luck.picture.lib.interfaces.OnResultCallbackListener;
import com.luck.picture.lib.utils.DateUtils;
import com.luck.picture.lib.utils.MediaUtils;
import com.luck.picture.lib.utils.PictureFileUtils;
import com.nswebkit.core.base.NSApplicationProvider;
import com.nswebkit.plugins.customcamera.NSGlideEngine;
import com.nswebkit.core.utils.NSImageUtil;

/**
 * @author Neil
 * @date 2023/5/30. description：基础插件
 */
public class NSCustomCameraPlugin extends CordovaPlugin {

    private final static String TAG = "NSCustomCameraPlugin";
    private String[] imagePermissions = {permission.WRITE_EXTERNAL_STORAGE};
    private String requestArgs;
    private CallbackContext callbackContext;
    private JSONObject jsonObject;
    private JSONObject callbackObject;
    private String sourceType = "camera";//默认拍照
    private int count = 1;
    private String finalSizeType = null;

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
        if ("saveImageToPhotosAlbum".equals(action)) {
            if (!hasPermisssion(imagePermissions)) {
                requestPermissions(1, imagePermissions);
            } else {
                String base64Image = jsonObject.optString("base64Image", "");
                saveImageToPhotosAlbum(base64Image, callbackContext);
            }
            return true;
        } else if ("compressImage".equals(action)) {
            String base64Image = jsonObject.optString("base64Image", "");
            long maxLength = jsonObject.optLong("maxLength", 500 * 1024);
            JSONObject callbackObject = new JSONObject();
            Bitmap bitmap = NSImageUtil.convertBase64ToPic(base64Image);
            NSImageUtil.compressImage(this.cordova.getActivity(), bitmap, maxLength, new NSImageUtil.OnCompressCallback() {
                @Override
                public void onSuccess(String base64) {
                    try {
                        callbackObject.put("errorMsg", "success");
                        callbackObject.put("base64Image", base64);
                        callbackContext.success(callbackObject);
                    } catch (JSONException e) {
                        throw new RuntimeException(e);
                    }
                }

                @Override
                public void onFail() {
                    try {
                        callbackObject.put("errCode", -1);
                        callbackObject.put("errorMsg", "压缩失败");
                        callbackContext.success(callbackObject);
                    } catch (JSONException e) {
                        throw new RuntimeException(e);
                    }
                }
            });
            return true;
        } else if ("chooseImage".equals(action)) {
            JSONArray sizeType = jsonObject.optJSONArray("sizeType");
            sourceType = jsonObject.optString("sourceType", "camera");//默认拍照
            count = jsonObject.optInt("count", 1);
            finalSizeType = null;
            if (sizeType !=null && sizeType.length() == 1) {
                if (sizeType.get(0).equals("original")) {//只要原图
                    finalSizeType = "original";
                } else if (sizeType.get(0).equals("compressed")) {//只要缩略图
                    finalSizeType = "compressed";
                }
            } else if (sizeType !=null && sizeType.length() == 2 && ((sizeType.get(0).equals("original") && sizeType.get(1).equals("compressed")) || (sizeType.get(0).equals("compressed") && sizeType.get(1).equals("original")))) {//原图缩略图都要
                finalSizeType = "all";
            } else {//默认压缩图
                finalSizeType = "compressed";
            }
            if (!hasPermisssion(imagePermissions)) {
                requestPermissions(2, imagePermissions);
            } else {
                chooseImage(finalSizeType, sourceType, count, callbackContext);
            }
            return true;
        } else {
            callbackObject.put("errCode", -2);
            callbackObject.put("errorMsg", "发生异常，请检查API使用是否正确");
            callbackContext.error(callbackObject.toString());
            return false;
        }
    }

    public String syncExecute(String action, String arguments) throws JSONException {
        return null;
    }

    public void saveImageToPhotosAlbum(String base64Image, CallbackContext callbackContext) throws JSONException {
        Bitmap bitmap = NSImageUtil.convertBase64ToPic(base64Image);
        NSImageUtil.saveBitmap(this.cordova.getActivity(), bitmap, callbackContext);
    }
    public void chooseImage(String sizeType, String sourceType, int count, CallbackContext callbackContext) {
        if (sourceType.equals("camera")) {//拍照
            PictureSelector.create(this.cordova.getActivity()).openCamera(SelectMimeType.ofImage()).setCompressEngine(new ImageFileCompressEngine()).forResultActivity(new OnResultCallbackListener<LocalMedia>() {
                @Override
                public void onResult(ArrayList<LocalMedia> result) {
                    callbackResult(result, sizeType, sourceType, count, callbackContext);
                }

                @Override
                public void onCancel() {
                    JSONObject callbackObject = new JSONObject();
                    try {
                        callbackObject.put("errCode", -1);
                        callbackObject.put("errorMsg", "取消");
                        callbackContext.success(callbackObject);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            });
        } else if (sourceType.equals("album")) {
            PictureSelector.create(this.cordova.getActivity()).openGallery(SelectMimeType.ofImage()).isOriginalControl(isOriginal(sizeType)).setMaxSelectNum(count).setImageEngine(NSGlideEngine.createGlideEngine()).setCompressEngine(new ImageFileCompressEngine()).forResult(new OnResultCallbackListener<LocalMedia>() {
                @Override
                public void onResult(ArrayList<LocalMedia> result) {
                    callbackResult(result, sizeType, sourceType, count, callbackContext);
                }

                @Override
                public void onCancel() {
                    JSONObject callbackObject = new JSONObject();
                    try {
                        callbackObject.put("errCode", -1);
                        callbackObject.put("errorMsg", "取消");
                        callbackContext.success(callbackObject);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            });
        }

    }


    private void callbackResult(ArrayList<LocalMedia> result, String sizeType, String sourceType, int count, CallbackContext callbackContext) {
        JSONObject callbackObject = new JSONObject();
        JSONArray jsonArray = new JSONArray();
        for (LocalMedia media : result) {
            if (media.getWidth() == 0 || media.getHeight() == 0) {
                if (PictureMimeType.isHasImage(media.getMimeType())) {
                    MediaExtraInfo imageExtraInfo = MediaUtils.getImageSize(NSApplicationProvider.getInstance().getApplication(), media.getPath());
                    media.setWidth(imageExtraInfo.getWidth());
                    media.setHeight(imageExtraInfo.getHeight());
                } else if (PictureMimeType.isHasVideo(media.getMimeType())) {
                    MediaExtraInfo videoExtraInfo = MediaUtils.getVideoSize(NSApplicationProvider.getInstance().getApplication(), media.getPath());
                    media.setWidth(videoExtraInfo.getWidth());
                    media.setHeight(videoExtraInfo.getHeight());
                }
            }
            Log.i(TAG, "文件名: " + media.getFileName());
            Log.i(TAG, "是否压缩:" + media.isCompressed());
            Log.i(TAG, "压缩:" + media.getCompressPath());
            Log.i(TAG, "初始路径:" + media.getPath());
            Log.i(TAG, "绝对路径:" + media.getRealPath());
            Log.i(TAG, "是否裁剪:" + media.isCut());
            Log.i(TAG, "裁剪路径:" + media.getCutPath());
            Log.i(TAG, "是否开启原图:" + media.isOriginal());
            Log.i(TAG, "原图路径:" + media.getOriginalPath());
            Log.i(TAG, "沙盒路径:" + media.getSandboxPath());
            Log.i(TAG, "水印路径:" + media.getWatermarkPath());
            Log.i(TAG, "视频缩略图:" + media.getVideoThumbnailPath());
            Log.i(TAG, "原始宽高: " + media.getWidth() + "x" + media.getHeight());
            Log.i(TAG, "裁剪宽高: " + media.getCropImageWidth() + "x" + media.getCropImageHeight());
            Log.i(TAG, "文件大小: " + PictureFileUtils.formatAccurateUnitFileSize(media.getSize()));
            Log.i(TAG, "文件时长: " + media.getDuration());
            JSONObject jsonObject = new JSONObject();
            try {
                boolean isBase64 = (sourceType.equals("album") || sourceType.equals("camera")) && count == 1;
                if (sizeType.equals("all")) {
                    jsonObject.put("originalURL", media.getOriginalPath());
                    jsonObject.put("original", media.getRealPath());
                    jsonObject.put("compressed", media.getCompressPath());
                    if (isBase64) {
                        jsonObject.put("originalBase64", NSImageUtil.imageToBase64(media.getRealPath()));
                        jsonObject.put("compressBase64", NSImageUtil.imageToBase64(media.getCompressPath()));
                    }
                } else if (sizeType.equals("original")) {
                    jsonObject.put("originalURL", media.getOriginalPath());
                    jsonObject.put("original", media.getRealPath());
                    if (isBase64) {
                        jsonObject.put("originalBase64", NSImageUtil.imageToBase64(media.getRealPath()));
                    }
                } else {
                    jsonObject.put("originalURL", media.getOriginalPath());
                    jsonObject.put("compressed", media.getCompressPath());
                    if (isBase64) {
                        jsonObject.put("compressBase64", NSImageUtil.imageToBase64(media.getCompressPath()));
                    }
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
            jsonArray.put(jsonObject);

        }
        try {
            callbackObject.put("errCode", 0);
            callbackObject.put("errorMsg", "success");
            callbackObject.put("data", jsonArray);
            callbackContext.success(callbackObject);
            Log.i(TAG, "文件: " + callbackObject);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private boolean isOriginal(String sizeType) {
        return sizeType.equals("all") || sizeType.equals("original");
    }

    /**
     * 自定义压缩
     */
    private static class ImageFileCompressEngine implements CompressFileEngine {

        @Override
        public void onStartCompress(Context context, ArrayList<Uri> source, OnKeyValueResultCallbackListener call) {
            Luban.with(context).load(source).ignoreBy(100).setRenameListener(new OnRenameListener() {
                @Override
                public String rename(String filePath) {
                    int indexOf = filePath.lastIndexOf(".");
                    String postfix = indexOf != -1 ? filePath.substring(indexOf) : ".jpg";
                    return DateUtils.getCreateFileName("CMP_") + postfix;
                }
            }).filter(new CompressionPredicate() {
                @Override
                public boolean apply(String path) {
                    if (PictureMimeType.isUrlHasImage(path) && !PictureMimeType.isHasHttp(path)) {
                        return true;
                    }
                    return !PictureMimeType.isUrlHasGif(path);
                }
            }).setCompressListener(new OnNewCompressListener() {
                @Override
                public void onStart() {

                }

                @Override
                public void onSuccess(String source, File compressFile) {
                    if (call != null) {
                        call.onCallback(source, compressFile.getAbsolutePath());
                    }
                }

                @Override
                public void onError(String source, Throwable e) {
                    if (call != null) {
                        call.onCallback(source, null);
                    }
                }
            }).launch();
        }
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
            case 1://保存相册
                String base64Image = jsonObject.optString("base64Image", "");
                saveImageToPhotosAlbum(base64Image, callbackContext);
                break;
            case 2://存储权限
                chooseImage(finalSizeType, sourceType, count, callbackContext);
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
