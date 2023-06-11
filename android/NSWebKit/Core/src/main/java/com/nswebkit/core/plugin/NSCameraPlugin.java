package com.nswebkit.core.plugin;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;

import androidx.core.content.FileProvider;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PermissionHelper;
import org.apache.cordova.PluginResult;
import org.apache.cordova.engine.SystemWebViewEngine;
import org.json.JSONArray;
import org.json.JSONException;

import java.io.File;

/**
 * @author Neil
 * @date 2023/5/17. description：input标签拉起摄像头
 */
public class NSCameraPlugin extends CordovaPlugin {

  protected final static String[] permissions = { Manifest.permission.CAMERA, Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE };
  private static final int FILECHOOSER_RESULTCODE = 5173;
  private CallbackContext callbackContext;
  private SystemWebViewEngine parentEngine;
  private boolean onlyCapture;
  private ValueCallback<Uri[]> filePathsCallback;
  private Intent selectIntent;
  public static final int PERMISSION_DENIED_ERROR = 20;

  @Override
  public boolean execute(String action, JSONArray args, CallbackContext callbackContext)
      throws JSONException {
    this.callbackContext = callbackContext;
    return super.execute(action, args, callbackContext);
  }

  public void callTakePicture(SystemWebViewEngine parentEngine,boolean onlyCapture,
      final ValueCallback<Uri[]> filePathsCallback,
      Intent selectIntent) {
    this.parentEngine = parentEngine;
    this.onlyCapture = onlyCapture;
    this.filePathsCallback = filePathsCallback;
    this.selectIntent = selectIntent;
    boolean saveAlbumPermission = PermissionHelper.hasPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)
        && PermissionHelper.hasPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE);
    boolean takePicturePermission = PermissionHelper.hasPermission(this, Manifest.permission.CAMERA);

    // CB-10120: The CAMERA permission does not need to be requested unless it is declared
    // in AndroidManifest.xml. This plugin does not declare it, but others may and so we must
    // check the package info to determine if the permission is present.

    if (!takePicturePermission) {
      takePicturePermission = true;
      try {
        PackageManager packageManager = this.cordova.getActivity().getPackageManager();
        String[] permissionsInPackage = packageManager.getPackageInfo(this.cordova.getActivity().getPackageName(), PackageManager.GET_PERMISSIONS).requestedPermissions;
        if (permissionsInPackage != null) {
          for (String permission : permissionsInPackage) {
            if (permission.equals(Manifest.permission.CAMERA)) {
              takePicturePermission = false;
              break;
            }
          }
        }
      } catch (NameNotFoundException e) {
        // We are requesting the info for our package, so this should
        // never be caught
      }
    }

    if (takePicturePermission && saveAlbumPermission) {

      try {
        int Act_type = getActType(selectIntent);//操作类型
        Intent captureIntent = null;    //照相或者摄像，捕获用的Intent
        String mCameraPhotoPath = null;   //照相时候的Path
        String showTitle = "";
        if (Act_type == 1){
          captureIntent = getTakePictureIntent();//拍照Intent
          mCameraPhotoPath = captureIntent.getStringExtra("filepath") + "";
          showTitle = "Image Chooser";
        }else if (Act_type == 2){
          captureIntent = getTakeVideoIntent();//摄像Intent 返回值会走intent.getData()
          showTitle = "video Chooser";
        }

        Intent[] intentArray = (captureIntent != null)? new Intent[]{captureIntent} : new Intent[2];
        //发起选择
        Intent chooserIntent = new Intent(Intent.ACTION_CHOOSER);
        chooserIntent.putExtra(Intent.EXTRA_INTENT, selectIntent);
        chooserIntent.putExtra(Intent.EXTRA_TITLE, showTitle);
        chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, intentArray);

        Intent f_intent = null;
        if (onlyCapture)  f_intent = captureIntent;
        else f_intent = Intent.createChooser(chooserIntent, showTitle);

        String finalMCameraPhotoPath = mCameraPhotoPath;
        parentEngine.getCordova().startActivityForResult(new CordovaPlugin() {
          @Override
          public void onActivityResult(int requestCode, int resultCode, Intent intent) {
            Uri[] result = null;
            if (resultCode == Activity.RESULT_OK) {
              if (intent != null) {
                result = __getFileUrisByIntent(intent);
              } else {
                // 添加图片到相册
                MediaScannerConnection.scanFile(parentEngine.getCordova().getContext().getApplicationContext(),
                    new String[]{finalMCameraPhotoPath}, null,
                    new MediaScannerConnection.OnScanCompletedListener() {
                      @Override
                      public void onScanCompleted(String path, Uri uri) {
                      }
                    });
                // File retFile = new File(mCameraPhotoPath);
                result = new Uri[]{Uri.parse("file:" + finalMCameraPhotoPath)};
              }
            }
            filePathsCallback.onReceiveValue(result);
          }
        }, f_intent, FILECHOOSER_RESULTCODE);
      }catch (Exception e){
        e.printStackTrace();
        filePathsCallback.onReceiveValue(null);
      }

    } else if (saveAlbumPermission && !takePicturePermission) {
      PermissionHelper.requestPermission(this, 0, Manifest.permission.CAMERA);
    } else if (!saveAlbumPermission && takePicturePermission) {
      PermissionHelper.requestPermissions(this, 0,
          new String[]{Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE});
    } else {
      PermissionHelper.requestPermissions(this, 0, permissions);
    }
  }

  private Intent getTakePictureIntent(){
    Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
    if (takePictureIntent.resolveActivity(parentEngine.getCordova().getActivity().getPackageManager()) != null) {
      // Create the File where the photo should go
      File photoFile = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES),
          "IMG_" + String.valueOf(System.currentTimeMillis()) + ".jpg");
      // Continue only if the File was successfully created
      if (photoFile != null) {
        String mCameraPhotoPath = photoFile.getAbsolutePath();
        System.out.println(parentEngine.getCordova().getContext());
        System.out.println(parentEngine.getCordova().getActivity().getPackageName());
        Uri photoUri = null;
        try {
          photoUri = FileProvider.getUriForFile(
                  parentEngine.getCordova().getContext(),
                  parentEngine.getCordova().getActivity().getPackageName() + ".provider",
                  photoFile);
        } catch (Exception e) {
          System.out.println(e);
        }
        takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoUri);
        takePictureIntent.putExtra(MediaStore.AUTHORITY, true);
        takePictureIntent.putExtra("return-data", true);
        takePictureIntent.putExtra("filepath", mCameraPhotoPath);
        takePictureIntent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
      } else {
        takePictureIntent = null;
      }
    }
    return takePictureIntent;
  }

  private Intent getTakeVideoIntent(){
    Intent intent = new Intent(MediaStore.ACTION_VIDEO_CAPTURE);
    //设置视频录制的最长时间
    intent.putExtra(MediaStore.EXTRA_DURATION_LIMIT, 15);
    //设置视频录制的画质
    intent.putExtra(MediaStore.EXTRA_VIDEO_QUALITY, 1);
    return intent;
  }

  private int getActType(Intent selectIntent){
    if (selectIntent != null) {
      String intent_type = selectIntent.getType();
      if (intent_type != null) {
        if (intent_type.indexOf("image/") == 0) {
          return 1;
        } else if (intent_type.indexOf("video/") == 0) {
          return 2;
        }
      }
    }
    return 0;
  }

  private Uri[] __getFileUrisByIntent(Intent intent){
    Uri[] result = null;
    if (intent != null) {
      //选择文件
      if (intent.getClipData() != null) {
        // handle multiple-selected files
        final int numSelectedFiles = intent.getClipData().getItemCount();
        result = new Uri[numSelectedFiles];
        for (int i = 0; i < numSelectedFiles; i++) {
          result[i] = intent.getClipData().getItemAt(i).getUri();
        }
      } else if (intent.getData() != null) {
        // handle single-selected file
        result = WebChromeClient.FileChooserParams.parseResult(Activity.RESULT_OK, intent);
      }
    }
    return result;
  }

  @Override
  public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults)
      throws JSONException {
    for (int r : grantResults) {
      if (r == PackageManager.PERMISSION_DENIED && null != this.callbackContext) {
        this.callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, PERMISSION_DENIED_ERROR));
        return;
      }
    }
    switch (requestCode) {
      case 0:
        callTakePicture(parentEngine,onlyCapture, filePathsCallback,selectIntent);
        break;

    }
  }
}
