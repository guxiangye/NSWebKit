package com.nswebkit.core.browser.view;

import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;

import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;

import com.nswebkit.core.R;


/**
 * 作者：Neil on 2023/5/30 16:59
 * <p>
 * www.github.com/guxiangyee/nswebkit.git
 * <p>
 * 作用： WebViewActivity
 */
public class NSWebViewActivity extends FragmentActivity {

  private NSWebViewFragment fragment;
  public final static String KEY_URL = "KEY_URL";
  public final static String KEY_THEME = "KEY_THEME";

  @Override
  public void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.webview_layout_activity);
    System.out.println(getIntent().getStringExtra(KEY_URL));
    System.out.println(getIntent().getStringExtra(KEY_THEME));
    fragment = new NSWebViewFragment(getIntent().getStringExtra(KEY_URL),getIntent().getStringExtra(KEY_THEME));
    getSupportFragmentManager().beginTransaction().add(R.id.web_view_root,fragment).commit();
  }

  @Override
  protected void onSaveInstanceState(Bundle outState) {
    fragment.mCordovaView.onSaveInstanceState(outState);
    super.onSaveInstanceState(outState);
  }

  @Override
  public boolean onKeyDown(int keyCode, KeyEvent event) {
    if (keyCode == KeyEvent.KEYCODE_BACK
            && null != fragment
            && null != fragment.mCordovaView
            && fragment.mCordovaView.getWebview().canGoBack()) {
      fragment.mCordovaView.getWebview().goBack();
      return true;
    }
    return super.onKeyDown(keyCode, event);
  }

  @Override
  public void startActivityForResult(Intent intent, int requestCode) {
    fragment.mCordovaView.startActivityForResult(intent, requestCode, null);
    super.startActivityForResult(intent, requestCode);
  }

  @Override
  public void onActivityResult(int requestCode, int resultCode, Intent data) {
    fragment.mCordovaView.onActivityResult(requestCode, resultCode, data);
    super.onActivityResult(requestCode, resultCode, data);
  }

  @Override
  public void onRequestPermissionsResult(int requestCode, String[] permissions,
      int[] grantResults) {
    fragment.mCordovaView.onRequestPermissionsResult(requestCode, permissions, grantResults);
    super.onRequestPermissionsResult(requestCode, permissions, grantResults);
  }

  @Override
  protected void onNewIntent(Intent intent) {
    super.onNewIntent(intent);
    fragment.mCordovaView.onNewIntent(intent);
  }

  @Override
  protected void onPause() {
    super.onPause();
      fragment.noticePageHide();
  }

  @Override
  protected void onResume() {
    super.onResume();
    fragment.noticePageShow();
  }

  public NSWebViewFragment getFragment() {
    return fragment;
  }
}
