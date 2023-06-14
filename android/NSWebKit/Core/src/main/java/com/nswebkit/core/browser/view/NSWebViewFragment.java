package com.nswebkit.core.browser.view;

import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

import com.nswebkit.core.BuildConfig;
import com.nswebkit.core.R;
import com.nswebkit.core.browser.manager.NSSystemWebChromeClient;
import com.nswebkit.core.browser.manager.NSSystemWebViewClient;
import com.nswebkit.core.iface.NSPluginInterface;
import com.nswebkit.core.utils.NSAppUtil;
import com.nswebkit.core.utils.NSColorUtil;
import com.nswebkit.core.utils.NSImageUtil;
import com.nswebkit.core.utils.NSStatusBarUtil;

import org.apache.cordova.engine.SystemWebViewEngine;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;

/**
 * @author Neil
 * @date 2023/5/11. description：WebViewFragment
 */

public class NSWebViewFragment extends Fragment implements NSPluginInterface, OnClickListener {

    private final static String TAG = "NSWebViewFragmentTag";
    protected NSCordovaView mCordovaView;
    private RelativeLayout mTitleBar, mErrorView;
    private ImageView mLeftBackBtn, mLeftClosBtn, mRightBtn;
    private TextView mTitleTv, mRightTv;
    private String url, theme, currentTitle, actionTxt, actionIcon;
    private boolean showCloseBtn, translucentStatusBars;
    private View root;
    //新打开页面是否需要显示返回按钮。
    private boolean newPageShowBack = false;
    // 存储主题样式 key：url ， value：主题（theme）
    private final HashMap<String, String> themeMap = new HashMap<>();
    private NSSystemWebChromeClient chromeClient;
    private boolean navigationBarHidden, showBackBtn, isBright;

    public NSWebViewFragment() {
    }

    public NSWebViewFragment(String url, String theme) {
        this.url = url;
        this.theme = theme;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        root = inflater.inflate(R.layout.webview_layout_fragment, container, false);
        mCordovaView = root.findViewById(R.id.web_view);
        mErrorView = root.findViewById(R.id.web_view_error);
        mTitleBar = root.findViewById(R.id.web_view_title_bar);
        mLeftBackBtn = root.findViewById(R.id.web_view_left_back_image);
        mLeftClosBtn = root.findViewById(R.id.web_view_left_close_image);
        mTitleTv = root.findViewById(R.id.web_view_title_text);
        mRightTv = root.findViewById(R.id.web_view_right_text);
        mRightBtn = root.findViewById(R.id.web_view_right_icon);
        mLeftBackBtn.setOnClickListener(this);
        mLeftClosBtn.setOnClickListener(this);
        mRightTv.setOnClickListener(this);
        mRightBtn.setOnClickListener(this);
        mErrorView.setOnClickListener(this);
        initWebView();
        initData();
        initTheme();
        return root;
    }

    private void initTheme() {
        try {
            // 默认主题
            JSONObject themeJson = new JSONObject();
            themeJson.put("title", "");
            themeJson.put("hidden", false);
            themeJson.put("titleColor", "000000");
            themeJson.put("color", "ffffff");
            themeJson.put("showBackButton", false);
            themeJson.put("showCloseButton", false);
            themeJson.put("actionTxt", "");
            themeJson.put("actionIcon", "");
            themeJson.put("isBright", false);
            themeJson.put("translucentStatusBars", false);
            if (!TextUtils.isEmpty(theme)) {
                JSONObject jsonObject = new JSONObject(theme);
                Iterator<String> it = jsonObject.keys();
                while (it.hasNext()) {
                    String key = it.next();
                    themeJson.put(key, jsonObject.get(key));
                }
            }
            theme = themeJson.toString();
            theme(theme);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void initWebView() {
        mCordovaView.initCordova(getActivity(), this);
        chromeClient = new NSSystemWebChromeClient((SystemWebViewEngine) mCordovaView.getWebview().getCordovaWebView().getEngine(), this);
        mCordovaView.getWebview().setWebChromeClient(chromeClient);
        mCordovaView.getWebview().setWebViewClient(new NSSystemWebViewClient((SystemWebViewEngine) mCordovaView.getWebview().getCordovaWebView().getEngine(), this));
        WebSettings webSettings = mCordovaView.getWebview().getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setSupportZoom(true);
        webSettings.setBuiltInZoomControls(false);
        webSettings.setUseWideViewPort(true);
        webSettings.setDomStorageEnabled(true);
        // 默认缓存机制
        webSettings.setCacheMode(WebSettings.LOAD_DEFAULT);
        webSettings.setLoadWithOverviewMode(true);
        webSettings.setDefaultFontSize(18);
        webSettings.setDefaultTextEncodingName("utf-8");
        webSettings.setJavaScriptCanOpenWindowsAutomatically(true);
        webSettings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
        webSettings.setLoadWithOverviewMode(false);
        webSettings.setUseWideViewPort(false);
        String userAgent = webSettings.getUserAgentString();
        webSettings.setUserAgentString(userAgent + " AppVersion/" + NSAppUtil.getAppVersionName());
        try {
            mCordovaView.getWebview().removeJavascriptInterface("searchBoxJavaBridge_");
            mCordovaView.getWebview().removeJavascriptInterface("accessibility");
            mCordovaView.getWebview().removeJavascriptInterface("accessibilityTraversal");
        } catch (Throwable tr) {
            tr.printStackTrace();
        }
    }

    private void initData() {
        Intent intent = getActivity().getIntent();
        if (!TextUtils.isEmpty(intent.getStringExtra("url"))) {
            url = intent.getStringExtra("url");
        }
        if (!TextUtils.isEmpty(intent.getStringExtra("theme"))) {
            theme = intent.getStringExtra("theme");
        }
        if (TextUtils.isEmpty(url)) {
            if (BuildConfig.DEBUG) {
                url = "www/index.html";
            } else {
                url = "about:blank";
            }
        }
        mCordovaView.loadUrl(url);
        newPageShowBack = intent.getBooleanExtra("showBackBtn", false);
        showBackBtn(mCordovaView.getWebview().canGoBack());
    }

    @Override
    public void theme(String theme) {
        getActivity().runOnUiThread(() -> {
            JSONObject jsonObject = null;
            try {
                jsonObject = new JSONObject(theme);
                if (jsonObject.has("hidden")) {
                    navigationBarHidden = jsonObject.getBoolean("hidden");
                }
                if (jsonObject.has("isBright")) {
                    isBright = jsonObject.getBoolean("isBright");
                }
                if (jsonObject.has("translucentStatusBars")) {
                    translucentStatusBars = jsonObject.getBoolean("translucentStatusBars");
                }
                // 如果亮色，设置状态栏文字为白色
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    if (isBright) {
                        getActivity().getWindow().setStatusBarColor(Color.parseColor(NSColorUtil.getColor("#ff000000")));
                        getActivity().getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_VISIBLE);
                    } else {
                        getActivity().getWindow().setStatusBarColor(Color.parseColor(NSColorUtil.getColor("#ffffff")));
                        getActivity().getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
                    }
                }

                if (!navigationBarHidden) {
                    mTitleBar.setVisibility(View.VISIBLE);
                    if (jsonObject.has("showBackButton")) {
                        showBackBtn = jsonObject.getBoolean("showBackButton");
                    }
                    if (jsonObject.has("showCloseButton")) {
                        showCloseBtn = jsonObject.getBoolean("showCloseButton");
                    }
                    String title = jsonObject.optString("title");
                    String titleColor = jsonObject.optString("titleColor");
                    String color_b = jsonObject.optString("color");
                    actionTxt = jsonObject.optString("actionTxt");
                    actionIcon = jsonObject.optString("actionIcon");
                    if (!TextUtils.isEmpty(title)) {
                        mTitleTv.setText(title);
                    }
                    if (!TextUtils.isEmpty(titleColor)) {
                        mTitleTv.setTextColor(Color.parseColor(NSColorUtil.getColor(titleColor)));
                        mLeftBackBtn.setColorFilter(Color.parseColor(NSColorUtil.getColor(titleColor)));
                        mLeftClosBtn.setColorFilter(Color.parseColor(NSColorUtil.getColor(titleColor)));
                        mRightTv.setTextColor(Color.parseColor(NSColorUtil.getColor(titleColor)));
                    }
                    if (!TextUtils.isEmpty(color_b)) {
                        mTitleBar.setBackgroundColor(Color.parseColor(NSColorUtil.getColor(color_b)));
                    }
                    showBackBtn(showBackBtn);
                    mLeftClosBtn.setVisibility(showCloseBtn ? View.VISIBLE : View.GONE);
                    if (!TextUtils.isEmpty(actionIcon)) {
                        mRightBtn.setVisibility(View.VISIBLE);
                        mRightTv.setVisibility(View.GONE);
                        mRightBtn.setImageBitmap(NSImageUtil.convertBase64ToPic(actionIcon));
                    } else {
                        mRightBtn.setVisibility(View.GONE);
                        if (TextUtils.isEmpty(actionTxt)) {
                            mRightTv.setVisibility(View.GONE);
                        } else {
                            mRightTv.setText(actionTxt);
                            mRightTv.setVisibility(View.VISIBLE);
                        }
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        // 设置状态栏底色颜色
                        getActivity().getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
                        getActivity().getWindow().clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
                        if (!TextUtils.isEmpty(color_b)) {
                            getActivity().getWindow().setStatusBarColor(Color.parseColor(NSColorUtil.getColor(color_b)));
                        }

                    }
                } else {
                    mTitleBar.setVisibility(View.GONE);
                    if (translucentStatusBars) {
                        // 设置 沉浸模式, 状态栏透明
                        NSStatusBarUtil.setTranslucentStatus(this.getActivity(), isBright);
//                        //一般的手机的状态栏文字和图标都是白色的, 可如果你的应用也是纯白色的, 或导致状态栏文字看不清
//                        //所以如果你是这种情况,请使用以下代码, 设置状态使用深色文字图标风格, 否则你可以选择性注释掉这个if内容
//                        if (!isBright) {
//                            //如果不支持设置深色风格 为了兼容总不能让状态栏白白的看不清, 于是设置一个状态栏颜色为半透明,
//                            //这样半透明+白=灰, 状态栏的文字能看得清
//                            NSStatusBarUtil.setStatusBarColor(this.getActivity(), 0x55000000);
//                        }
                    }
                }


            } catch (JSONException e) {
                e.printStackTrace();
            }
        });
    }

    private void showBackBtn(boolean b) {
        if (newPageShowBack) {
            mLeftBackBtn.setVisibility(View.VISIBLE);
        } else {
            if (b) {
                mLeftBackBtn.setVisibility(View.VISIBLE);
            } else {
                mLeftBackBtn.setVisibility(mCordovaView.getWebview().canGoBack() ? View.VISIBLE : View.GONE);
            }
        }
    }

//    @Override
//    public void scan(boolean hideAlbum, int scanType, CallbackContext callbackContext) {
//        getActivity().runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//                MNScanConfig scanConfig = new MNScanConfig.Builder()
//                        // 设置完成震动
//                        .isShowVibrate(true)
//                        // 扫描完成声音
//                        .isShowBeep(true)
//                        // 显示相册功能
//                        .isShowPhotoAlbum(!hideAlbum)
//                        // 显示闪光灯
//                        .isShowLightController(true)
//                        // 扫描线的颜色
//                        .setScanColor("#22CE6B")
//                        // 是否支持手势缩放
//                        .setSupportZoom(true)
//                        // 是否显示缩放控制器
//                        .isShowZoomController(true)
//                        // 显示缩放控制器位置
//                        .setZoomControllerLocation(MNScanConfig.ZoomControllerLocation.Right)
//                        // 扫描线样式
//                        .setLaserStyle(MNScanConfig.LaserStyle.Line)
//                        // 背景颜色
//                        .setBgColor("#22FF0000")
//                        // 是否全屏扫描,默认只扫描扫描框内的二维码
//                        .setFullScreenScan(true)
//                        // 二维码标记点
//                        .isShowResultPoint(true)
//                        // 是否支持多二维码同时扫出,默认false,多二维码状态不支持条形码
//                        .setSupportMultiQRCode(false)
//                        // 自定义遮罩
//                        .setCustomShadeViewLayoutID(0, null).setSupportCode(scanType).builder();
//                MNScanManager.startScan(getActivity(), scanConfig, new MNScanCallback() {
//                    @Override
//                    public void onActivityResult(int resultCode, Intent data) {
//                        JSONObject callbackObject = new JSONObject();
//                        switch (resultCode) {
//                            case MNScanManager.RESULT_SUCCESS:
//                                String resultSuccess = data.getStringExtra(MNScanManager.INTENT_KEY_RESULT_SUCCESS);
//                                String resultType = data.getStringExtra(MNScanManager.INTENT_KEY_RESULT_TYPE);
//                                try {
//                                    callbackObject.put("errCode", 0);
//                                    callbackObject.put("errorMsg", "success");
//                                    callbackObject.put("code", resultSuccess);
//                                    if (!TextUtils.isEmpty(resultType)) {
//                                        if (resultType.equals("QR_CODE")) {
//                                            resultType = "qrCode";
//                                        } else {
//                                            resultType = "barCode";
//                                        }
//                                    }
//                                    callbackObject.put("scanType", resultType);
//                                    Toast.makeText(getActivity(), resultSuccess, Toast.LENGTH_SHORT).show();
//                                    callbackContext.success(callbackObject);
//                                } catch (JSONException e) {
//                                    e.printStackTrace();
//                                }
//                                break;
//                            case MNScanManager.RESULT_FAIL:
//                                String resultError = data.getStringExtra(MNScanManager.INTENT_KEY_RESULT_ERROR);
//                                try {
//                                    callbackObject.put("errCode", -1);
//                                    callbackObject.put("errorMsg", resultError);
//                                    callbackContext.success(callbackObject);
//                                } catch (JSONException e) {
//                                    e.printStackTrace();
//                                }
//                                callbackContext.success(resultError);
//                                break;
//                            case MNScanManager.RESULT_CANCLE:
//                                try {
//                                    callbackObject.put("errCode", -2);
//                                    callbackObject.put("errorMsg", "扫码关闭");
//                                    callbackContext.error("Unexpected error");
//                                } catch (JSONException e) {
//                                    e.printStackTrace();
//                                }
//                                break;
//                        }
//                    }
//                });
//            }
//        });
//    }

//    private void callbackResult(ArrayList<LocalMedia> result, String sizeType, String sourceType, int count, CallbackContext callbackContext) {
//        JSONObject callbackObject = new JSONObject();
//        JSONArray jsonArray = new JSONArray();
//        for (LocalMedia media : result) {
//            if (media.getWidth() == 0 || media.getHeight() == 0) {
//                if (PictureMimeType.isHasImage(media.getMimeType())) {
//                    MediaExtraInfo imageExtraInfo = MediaUtils.getImageSize(NSApplicationProvider.getInstance().getApplication(), media.getPath());
//                    media.setWidth(imageExtraInfo.getWidth());
//                    media.setHeight(imageExtraInfo.getHeight());
//                } else if (PictureMimeType.isHasVideo(media.getMimeType())) {
//                    MediaExtraInfo videoExtraInfo = MediaUtils.getVideoSize(NSApplicationProvider.getInstance().getApplication(), media.getPath());
//                    media.setWidth(videoExtraInfo.getWidth());
//                    media.setHeight(videoExtraInfo.getHeight());
//                }
//            }
////            Log.i(TAG, "文件名: " + media.getFileName());
////            Log.i(TAG, "是否压缩:" + media.isCompressed());
////            Log.i(TAG, "压缩:" + media.getCompressPath());
////            Log.i(TAG, "初始路径:" + media.getPath());
////            Log.i(TAG, "绝对路径:" + media.getRealPath());
////            Log.i(TAG, "是否裁剪:" + media.isCut());
////            Log.i(TAG, "裁剪路径:" + media.getCutPath());
////            Log.i(TAG, "是否开启原图:" + media.isOriginal());
////            Log.i(TAG, "原图路径:" + media.getOriginalPath());
////            Log.i(TAG, "沙盒路径:" + media.getSandboxPath());
////            Log.i(TAG, "水印路径:" + media.getWatermarkPath());
////            Log.i(TAG, "视频缩略图:" + media.getVideoThumbnailPath());
////            Log.i(TAG, "原始宽高: " + media.getWidth() + "x" + media.getHeight());
////            Log.i(TAG, "裁剪宽高: " + media.getCropImageWidth() + "x" + media.getCropImageHeight());
////            Log.i(TAG, "文件大小: " + PictureFileUtils.formatAccurateUnitFileSize(media.getSize()));
////            Log.i(TAG, "文件时长: " + media.getDuration());
//            JSONObject jsonObject = new JSONObject();
////            String base64 = NSImageUtil.imageToBase64(media.getRealPath());
////            Log.i(TAG, "originalBase64: " + base64);
//            try {
//                boolean isBase64 = (sourceType.equals("album") || sourceType.equals("camera")) && count == 1;
//                if (sizeType.equals("all")) {
//                    jsonObject.put("originalURL", media.getOriginalPath());
//                    jsonObject.put("original", media.getRealPath());
//                    jsonObject.put("compressed", media.getCompressPath());
//                    if (isBase64) {
//                        jsonObject.put("originalBase64", NSImageUtil.imageToBase64(media.getRealPath()));
//                        jsonObject.put("compressBase64", NSImageUtil.imageToBase64(media.getCompressPath()));
//                    }
//                } else if (sizeType.equals("original")) {
//                    jsonObject.put("originalURL", media.getOriginalPath());
//                    jsonObject.put("original", media.getRealPath());
//                    if (isBase64) {
//                        jsonObject.put("originalBase64", NSImageUtil.imageToBase64(media.getRealPath()));
//                    }
//                } else {
//                    jsonObject.put("originalURL", media.getOriginalPath());
//                    jsonObject.put("compressed", media.getCompressPath());
//                    if (isBase64) {
//                        jsonObject.put("compressBase64", NSImageUtil.imageToBase64(media.getCompressPath()));
//                    }
//                }
//            } catch (JSONException e) {
//                e.printStackTrace();
//            }
//            jsonArray.put(jsonObject);
//
//        }
//        try {
//            callbackObject.put("errCode", 0);
//            callbackObject.put("errorMsg", "success");
//            callbackObject.put("data", jsonArray);
//            callbackContext.success(callbackObject);
//            Log.i(TAG, "文件: " + callbackObject);
//        } catch (JSONException e) {
//            e.printStackTrace();
//        }
//    }
//
//    private boolean isOriginal(String sizeType) {
//        return sizeType.equals("all") || sizeType.equals("original");
//    }
//
//    /**
//     * 自定义压缩
//     */
//    private static class ImageFileCompressEngine implements CompressFileEngine {
//
//        @Override
//        public void onStartCompress(Context context, ArrayList<Uri> source, OnKeyValueResultCallbackListener call) {
//            Luban.with(context).load(source).ignoreBy(100).setRenameListener(new OnRenameListener() {
//                @Override
//                public String rename(String filePath) {
//                    int indexOf = filePath.lastIndexOf(".");
//                    String postfix = indexOf != -1 ? filePath.substring(indexOf) : ".jpg";
//                    return DateUtils.getCreateFileName("CMP_") + postfix;
//                }
//            }).filter(new CompressionPredicate() {
//                @Override
//                public boolean apply(String path) {
//                    if (PictureMimeType.isUrlHasImage(path) && !PictureMimeType.isHasHttp(path)) {
//                        return true;
//                    }
//                    return !PictureMimeType.isUrlHasGif(path);
//                }
//            }).setCompressListener(new OnNewCompressListener() {
//                @Override
//                public void onStart() {
//
//                }
//
//                @Override
//                public void onSuccess(String source, File compressFile) {
//                    if (call != null) {
//                        call.onCallback(source, compressFile.getAbsolutePath());
//                    }
//                }
//
//                @Override
//                public void onError(String source, Throwable e) {
//                    if (call != null) {
//                        call.onCallback(source, null);
//                    }
//                }
//            }).launch();
//        }
//    }


    @Override
    public void onClick(View v) {
        if (v == mLeftBackBtn) {
            if (mCordovaView.getWebview().canGoBack()) {
                mCordovaView.getWebview().goBack();
            } else {
                getActivity().finish();
            }
        } else if (v == mLeftClosBtn) {
            getActivity().finish();
        } else if (v == mRightTv || v == mRightBtn) {
            JSONObject jsonObject = new JSONObject();
            JSONObject actionObject = new JSONObject();
            try {
                if (!TextUtils.isEmpty(actionIcon)) {
                    actionObject.put("actionIcon", actionIcon);
                } else {
                    actionObject.put("actionTxt", actionTxt);
                }
                jsonObject.put("handlerName", "rightActionCallback");
                jsonObject.put("data", actionObject);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            mCordovaView.getWebview().evaluateJavascript("ns.handleMessageFromNative('" + jsonObject + "')", null);
        } else if (v == mErrorView) {
            mCordovaView.getWebview().reload();
//            mErrorView.setVisibility(View.GONE);
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        mCordovaView.onResume();
    }

    @Override
    public void onPause() {
        super.onPause();
        if (null != mCordovaView) {
            mCordovaView.onPause();
        }
    }

    @Override
    public void onStart() {
        super.onStart();
        if (null != mCordovaView) {
            mCordovaView.onStart();
        }
    }

    @Override
    public void onStop() {
        super.onStop();
        if (null != mCordovaView) {
            mCordovaView.onStop();
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (null != mCordovaView) {
            mCordovaView.onDestroy();
        }
    }

    public View getRoot() {
        return root;
    }

    public NSCordovaView getCordovaView() {
        return mCordovaView;
    }

    @Override
    public void onReceivedTitle(WebView view, String title) {
        if (themeMap.size() == 0 || themeMap.get(mCordovaView.getWebview().getUrl()) == null) {
            themeMap.put(mCordovaView.getWebview().getUrl(), theme);
            theme(theme);
        } else {
            theme(themeMap.get(mCordovaView.getWebview().getUrl()));
        }
        // 标题改变，隐藏右侧按钮
        mRightTv.setVisibility(title.equals(currentTitle) ? View.VISIBLE : View.GONE);
        // 标题改变，隐藏关闭按钮
//        mLeftClosBtn.setVisibility(title.equals(currentTitle) ? View.VISIBLE : View.GONE);
        currentTitle = title;
        if (!TextUtils.isEmpty(title)) {
            mTitleTv.setText(title);
        }
        mErrorView.setVisibility(title.equals("网页无法打开") ? View.VISIBLE : View.GONE);
    }

    @Override
    public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {

    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        chromeClient.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        super.onHiddenChanged(hidden);
        if (hidden) {
            noticePageHide();
        } else {
            noticePageShow();
        }
    }

    public void noticePageHide() {
        mCordovaView.getWebview().evaluateJavascript("ns.noticePageHide()", null);
    }

    public void noticePageShow() {
        mCordovaView.getWebview().evaluateJavascript("ns.noticePageShow()", null);
    }
}
