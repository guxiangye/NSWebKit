package com.nswebkit.core.browser.manager;

import android.graphics.Bitmap;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;

import com.nswebkit.core.iface.NSPluginInterface;
import com.nswebkit.core.utils.NSFileUtil;

import org.apache.cordova.engine.SystemWebViewClient;
import org.apache.cordova.engine.SystemWebViewEngine;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.net.URLConnection;


public class NSSystemWebViewClient extends SystemWebViewClient {

  private boolean isInjection = false;
  private NSPluginInterface pluginInterface;
  public String NSSchemeKey = "nsfile://";

  public NSSystemWebViewClient(SystemWebViewEngine parentEngine) {
    super(parentEngine);
  }

  public NSSystemWebViewClient(SystemWebViewEngine parentEngine, NSPluginInterface pluginInterface) {
    super(parentEngine);
    this.pluginInterface = pluginInterface;
  }

  @Override
  public WebResourceResponse shouldInterceptRequest(WebView view, String url) {
    if (url.startsWith(NSSchemeKey) && (url.contains("sdcard") || url.contains("storage"))) {
      try {
        // Load the image from the URL into the WebView
        InputStream is = new FileInputStream(new File(url.replace(NSSchemeKey,"")));
        String mimeType = URLConnection.guessContentTypeFromName(url);
        WebResourceResponse response = new WebResourceResponse(mimeType, "UTF-8", is);
        return response;
      } catch (FileNotFoundException e) {
        e.printStackTrace();
      }
    }
    return super.shouldInterceptRequest(view, url);
  }

  @Override
  public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
    this.pluginInterface.onReceivedError(view, errorCode, description, failingUrl);
  }

  @Override
  public void onPageStarted(WebView view, String url, Bitmap favicon) {
    if (!isInjection) {
      view.evaluateJavascript(NSFileUtil.loadAssetJs("www/cordova.js"), null);
      view.evaluateJavascript(NSFileUtil.loadAssetJs("www/cordova_plugins.js"), null);
      view.evaluateJavascript(
              NSFileUtil.loadAssetJs(
                      "www/plugins/cordova-plugin-background-mode/www/background-mode.js"),
              null);
      view.evaluateJavascript(
              NSFileUtil.loadAssetJs("www/plugins/cordova-plugin-inappbrowser/www/inappbrowser.js"),
              null);
      view.evaluateJavascript(
              NSFileUtil.loadAssetJs("www/plugins/cordova-plugin-device/www/device.js"), null);
      view.evaluateJavascript(
              NSFileUtil.loadAssetJs("www/plugins/cordova-plugin-camera/www/CameraPopoverHandle.js"),
              null);
      view.evaluateJavascript(
              NSFileUtil.loadAssetJs("www/plugins/cordova-plugin-camera/www/Camera.js"), null);
      view.evaluateJavascript(
              NSFileUtil.loadAssetJs("www/plugins/cordova-plugin-camera/www/CameraPopoverOptions.js"),
              null);
      view.evaluateJavascript(
              NSFileUtil.loadAssetJs("www/plugins/cordova-plugin-camera/www/CameraConstants.js"), null);
      view.evaluateJavascript(
              NSFileUtil.loadAssetJs(
                      "www/plugins/cordova-plugin-network-information/www/Connection.js"),
              null);
      view.evaluateJavascript(
              NSFileUtil.loadAssetJs("www/plugins/cordova-plugin-network-information/www/network.js"),
              null);
      view.evaluateJavascript(NSFileUtil.loadAssetJs("www/ns.js"), null);
      view.evaluateJavascript("window.ns.isLocal = true", null);
      isInjection = true;
    }

    super.onPageStarted(view, url, favicon);
  }

  @Override
  public void onPageFinished(WebView view, String url) {
    super.onPageFinished(view, url);
  }
}
