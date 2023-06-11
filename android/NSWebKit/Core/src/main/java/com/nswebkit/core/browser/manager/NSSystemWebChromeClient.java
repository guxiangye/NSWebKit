package com.nswebkit.core.browser.manager;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.text.TextUtils;
import android.webkit.GeolocationPermissions;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebView;

import androidx.annotation.NonNull;

import com.nswebkit.core.iface.NSPluginInterface;
import com.nswebkit.core.plugin.NSCameraPlugin;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;
import org.apache.cordova.engine.SystemWebChromeClient;
import org.apache.cordova.engine.SystemWebViewEngine;


public class NSSystemWebChromeClient extends SystemWebChromeClient {

  public static final int locationRequestCode = 10005;
  private GeolocationPermissions.Callback locationCallback;
  private String origin;
  private NSPluginInterface pluginInterface;

  public NSSystemWebChromeClient(SystemWebViewEngine parentEngine) {
    super(parentEngine);
  }

  public NSSystemWebChromeClient(SystemWebViewEngine parentEngine, NSPluginInterface pluginInterface) {
    super(parentEngine);
    this.pluginInterface = pluginInterface;
  }


  @Override
  public void onReceivedTitle(WebView view, String title) {
    this.pluginInterface.onReceivedTitle(view, title);
  }

  @Override
  public void onGeolocationPermissionsShowPrompt(String origin,
      GeolocationPermissions.Callback callback) {
    this.locationCallback = callback;
    this.origin = origin;
    SystemWebViewEngine parentEngine = this.parentEngine;
    CordovaPlugin locationPlugin = parentEngine.getCordovaWebView().getPluginManager().getPlugin("NSLocationPlugin");
    if (locationPlugin != null) {
      if (!locationPlugin.hasPermisssion()) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
          locationPlugin.requestPermissions(locationRequestCode);
        } else {
          callback.invoke(origin, true, false);
        }
      } else {
        callback.invoke(origin, true, false);
      }
    }
  }

  public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
      @NonNull int[] grantResults) {
    if (requestCode == locationRequestCode && null != locationCallback && !TextUtils.isEmpty(
        origin)) {
      locationCallback.invoke(origin, true, false);
    }
  }

  @Override
  public boolean onShowFileChooser(
      WebView webView,
      ValueCallback<Uri[]> filePathsCallback,
      FileChooserParams fileChooserParams) {
    // Check if multiple-select is specified
    Boolean selectMultiple = false;
    if (fileChooserParams.getMode() == WebChromeClient.FileChooserParams.MODE_OPEN_MULTIPLE) {
      selectMultiple = true;
    }
    Intent intent = fileChooserParams.createIntent();
    intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, selectMultiple);

    // Uses Intent.EXTRA_MIME_TYPES to pass multiple mime types.
    String[] acceptTypes = fileChooserParams.getAcceptTypes();
    if (acceptTypes.length > 1) {
      intent.setType("*/*"); // Accept all, filter mime types by Intent.EXTRA_MIME_TYPES.
      intent.putExtra(Intent.EXTRA_MIME_TYPES, acceptTypes);
    }
    boolean isCapture = fileChooserParams.isCaptureEnabled();
    try {
      //      String intent_type = intent.getType();
      if (getActType(intent) > 0) {
        ((NSCameraPlugin)
            parentEngine.getCordovaWebView().getPluginManager().getPlugin("InputCamera"))
            .callTakePicture(parentEngine, isCapture, filePathsCallback, intent);
      } else {
        parentEngine
            .getCordova()
            .startActivityForResult(
                new CordovaPlugin() {
                  @Override
                  public void onActivityResult(int requestCode, int resultCode, Intent intent) {
                    Uri[] result = null;
                    if (resultCode == Activity.RESULT_OK && intent != null) {
                      result = __getFileUrisByIntent(intent);
                    }
                    filePathsCallback.onReceiveValue(result);
                  }
                },
                intent,
                5173);
      }
    } catch (ActivityNotFoundException e) {
      LOG.w("No activity found to handle file chooser intent.", e);
      filePathsCallback.onReceiveValue(null);
    }
    return true;
  }

  private int getActType(Intent selectIntent) {
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

  private Uri[] __getFileUrisByIntent(Intent intent) {
    Uri[] result = null;
    if (intent != null) {
      // 选择文件
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
}
