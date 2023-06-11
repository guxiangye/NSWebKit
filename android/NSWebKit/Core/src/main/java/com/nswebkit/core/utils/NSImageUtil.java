package com.nswebkit.core.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Environment;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.util.Base64;
import android.util.Log;
import android.widget.Toast;

import org.apache.cordova.CallbackContext;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import top.zibin.luban.CompressionPredicate;
import top.zibin.luban.Luban;
import top.zibin.luban.OnCompressListener;

/**
 * @author Neil
 * @date 2023/5/20. description：
 */
public class NSImageUtil {

    public static Bitmap convertBase64ToPic(String base64) {
        String value = base64;
        if (base64.contains(",")) {
            value = base64.split(",")[1];
        }
        byte[] decode = Base64.decode(value, Base64.DEFAULT);
        return BitmapFactory.decodeByteArray(decode, 0, decode.length);
    }

    public static void saveBitmap(Context context, Bitmap bitmap, CallbackContext callbackContext) throws JSONException {
        JSONObject callbackObject = new JSONObject();
        String insertImage = MediaStore.Images.Media.insertImage(context.getContentResolver(), bitmap, "IMG_" + String.valueOf(System.currentTimeMillis()) + ".jpg", "");
        if (TextUtils.isEmpty(insertImage)) {
            callbackObject.put("errCode", -1);
            callbackObject.put("errorMsg", "fail");
        } else {
            callbackObject.put("errCode", 0);
            callbackObject.put("errorMsg", "success");
        }
        callbackContext.success(callbackObject);

//        File photoFile = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), "IMG_" + String.valueOf(System.currentTimeMillis()) + ".jpg");
//        try {
//            FileOutputStream fos = new FileOutputStream(photoFile);
//            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fos);
//            fos.flush();
//            fos.close();
//
//        } catch (Exception e) {
//            callbackObject.put("errCode", -1);
//            callbackObject.put("errorMsg", e.getLocalizedMessage());
//            callbackContext.success(callbackObject);
//            e.printStackTrace();
//        }
//
//        // 把文件插入到系统图库
//        try {
//            MediaStore.Images.Media.insertImage(context.getContentResolver(), photoFile.getAbsolutePath(), photoFile.getName(), null);
//        } catch (FileNotFoundException e) {
//            e.printStackTrace();
//        }
//        // 通知图库更新
//        context.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + "/sdcard/namecard/")));
    }

    /**
     * 图片按比例大小压缩方法
     *
     * @param image （根据Bitmap图片压缩）
     * @return
     */
    public static void compressImage(Context context, Bitmap image, long maxLength,OnCompressCallback callback) {
        File photoFile = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), "IMG_" + System.currentTimeMillis() + ".jpg");
        try {
            FileOutputStream fos = new FileOutputStream(photoFile);
            image.compress(Bitmap.CompressFormat.JPEG, 100, fos);
            fos.flush();
            fos.close();
        } catch (Exception e) {
            callback.onFail();
            e.printStackTrace();
        }
        Luban.with(context).load(photoFile.getAbsoluteFile()).ignoreBy(100).setTargetDir(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES).getAbsolutePath()).filter(new CompressionPredicate() {
            @Override
            public boolean apply(String path) {
                return !(TextUtils.isEmpty(path) || path.toLowerCase().endsWith(".gif"));
            }
        }).setCompressListener(new OnCompressListener() {
            @Override
            public void onStart() {
                Toast.makeText(context, "开始", Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onSuccess(int index, File compressFile) {
                if (compressFile.length() > maxLength) {//大于最大要求大小,继续按比例压缩
                    String base64 = fileToBitmap(compressFile, maxLength);
                    callback.onSuccess(base64);
                } else {
                    Bitmap bitmap = BitmapFactory.decodeFile(compressFile.getAbsolutePath());
                    String base64 = bitmapToBase64(bitmap);
                    callback.onSuccess(base64);
                }
                File file = new File(compressFile.getAbsolutePath());
                if(file.exists()){
                    file.delete();
                }
                File originalFile = new File(photoFile.getAbsolutePath());
                if(originalFile.exists()){
                    originalFile.delete();
                }
            }

            @Override
            public void onError(int index, Throwable e) {
                callback.onFail();
            }
        }).launch();
    }

    public interface OnCompressCallback {
        void onSuccess(String base64);
        void onFail();
    }


    private static String fileToBitmap(File compressFile, long maxLength) {
        Log.d("zhangbuniao", "期望大小：" + maxLength / 1024 + "k");
        Bitmap bitmap = BitmapFactory.decodeFile(compressFile.getAbsolutePath());
        String base64 = bitmapToBase64(bitmap);
        Log.d("zhangbuniao", "压缩前大小：" + base64.length() / 1024 + "k");
        while (base64.length() > maxLength) {
            Log.d("zhangbuniao", "压缩前大小01：" + base64.length() / 1024 + "k");
            base64 = compressScale(bitmap);
            bitmap = convertBase64ToPic(base64);
            Log.d("zhangbuniao", "压缩后大小：" + base64.length() / 1024 + "k");
        }
        return base64;
    }

    public static String compressScale(Bitmap image) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        image.compress(Bitmap.CompressFormat.JPEG, 100, baos);
        ByteArrayInputStream isBm = new ByteArrayInputStream(baos.toByteArray());
        BitmapFactory.Options newOpts = new BitmapFactory.Options();
        // 开始读入图片，此时把options.inJustDecodeBounds 设回true了
        newOpts.inJustDecodeBounds = true;
        Bitmap bitmap = BitmapFactory.decodeStream(isBm, null, newOpts);
        newOpts.inJustDecodeBounds = false;
        int w = newOpts.outWidth;
        int h = newOpts.outHeight;
        float hh = (float) (h * 0.5);
        float ww = (float) (w * 0.5);
        int be = 1;// be=1表示不缩放
        if (w > h && w > ww) {// 如果宽度大的话根据宽度固定大小缩放
            be = (int) (newOpts.outWidth / ww);
        } else if (w < h && h > hh) { // 如果高度高的话根据高度固定大小缩放
            be = (int) (newOpts.outHeight / hh);
        }
        if (be <= 0) be = 1;
        newOpts.inSampleSize = be; // 设置缩放比例
        // newOpts.inPreferredConfig = Config.RGB_565;//降低图片从ARGB888到RGB565
        // 重新读入图片，注意此时已经把options.inJustDecodeBounds 设回false了
        isBm = new ByteArrayInputStream(baos.toByteArray());
        bitmap = BitmapFactory.decodeStream(isBm, null, newOpts);
        return bitmapToBase64(bitmap);
    }

    private static Bitmap base64ToBitmap(String base64) {
        Bitmap bitmap = null;
        try {
            byte[] bitmapByte = Base64.decode(base64, Base64.DEFAULT);
            bitmap = BitmapFactory.decodeByteArray(bitmapByte, 0, bitmapByte.length);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return bitmap;
    }

    public static String bitmapToBase64(Bitmap bitmap) {
        String result = null;
        ByteArrayOutputStream baos = null;
        try {
            if (bitmap != null) {
                baos = new ByteArrayOutputStream();
                bitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
                baos.flush();
                baos.close();
                byte[] bitmapBytes = baos.toByteArray();
                result = Base64.encodeToString(bitmapBytes, Base64.DEFAULT);
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (baos != null) {
                    baos.flush();
                    baos.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        if (null != result && result.contains(",")) {
            result = result.split(",")[1];
//            result = "data:image/jpeg;base64," + result;
        }
        return result;
    }

    public static String imageToBase64(String path) {
        if (TextUtils.isEmpty(path)) {
            return null;
        }
        InputStream is = null;
        byte[] data = null;
        String result = null;
        try {
            is = new FileInputStream(path);
            //创建一个字符流大小的数组。
            data = new byte[is.available()];
            //写入数组
            is.read(data);
            //用默认的编码格式进行编码
            result = Base64.encodeToString(data, Base64.DEFAULT);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (null != is) {
                try {
                    is.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }

        }
        if (null != result && result.contains(",")) {
            result = result.split(",")[1];
//            result = "data:image/jpeg;base64," + result;
        }
        return result;
    }


}
