package com.nswebkit.core.browser.manager;

import android.graphics.Bitmap;
import android.webkit.WebView;

import com.nswebkit.core.iface.NSPluginInterface;
import com.nswebkit.core.utils.NSFileUtil;

import org.apache.cordova.engine.SystemWebViewClient;
import org.apache.cordova.engine.SystemWebViewEngine;


public class NSSystemWebViewClient extends SystemWebViewClient {

  private boolean isInjection = false;
  private NSPluginInterface pluginInterface;

  public NSSystemWebViewClient(SystemWebViewEngine parentEngine) {
    super(parentEngine);
  }

  public NSSystemWebViewClient(SystemWebViewEngine parentEngine, NSPluginInterface pluginInterface) {
    super(parentEngine);
    this.pluginInterface = pluginInterface;
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
