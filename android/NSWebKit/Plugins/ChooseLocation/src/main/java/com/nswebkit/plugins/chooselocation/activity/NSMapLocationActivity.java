package com.nswebkit.plugins.chooselocation.activity;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Point;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.provider.Settings;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.amap.api.maps.AMap;
import com.amap.api.maps.AMapOptions;
import com.amap.api.maps.AMapUtils;
import com.amap.api.maps.CameraUpdateFactory;
import com.amap.api.maps.LocationSource;
import com.amap.api.maps.MapView;

import com.amap.api.maps.model.BitmapDescriptorFactory;
import com.amap.api.maps.model.CameraPosition;
import com.amap.api.maps.model.LatLng;
import com.amap.api.maps.model.Marker;
import com.amap.api.maps.model.MarkerOptions;
import com.amap.api.maps.model.MyLocationStyle;
import com.amap.api.maps.model.Poi;
import com.amap.api.services.core.AMapException;
import com.amap.api.services.core.LatLonPoint;
import com.amap.api.services.core.PoiItemV2;
import com.amap.api.services.poisearch.PoiResultV2;
import com.amap.api.services.poisearch.PoiSearchV2;
import com.amap.api.services.poisearch.PoiSearchV2.Query;
import com.nswebkit.core.utils.NSAppUtil;
import com.nswebkit.plugins.chooselocation.utils.NSMapLocationParam;
import com.scwang.smart.refresh.footer.ClassicsFooter;
import com.scwang.smart.refresh.layout.SmartRefreshLayout;
import com.nswebkit.plugins.chooselocation.R;
import com.nswebkit.plugins.chooselocation.adapter.NSRecyclerAdapter;
import com.nswebkit.plugins.chooselocation.utils.NSStatusBarUtil;
import com.nswebkit.plugins.chooselocation.utils.NSViewUtil;
import com.nswebkit.plugins.chooselocation.widget.NSDrawerLayout;
import com.nswebkit.plugins.chooselocation.widget.NSDrawerLayout.Status;

import org.json.JSONException;
import org.json.JSONObject;


/**
 * @date 2023/6/1 on 13:37 @author: neil
 */
public class NSMapLocationActivity extends Activity implements OnClickListener, LocationSource, AMapLocationListener, AMap.OnCameraChangeListener, PoiSearchV2.OnPoiSearchListener, AMap.OnMapClickListener, AMap.OnPOIClickListener {

    NSMapLocationParam param;
    private Marker screenMarker;
    private Marker keywordPointMaker;
    private boolean isLocated;//首次定位标记


    private boolean needSearchNearbyPOI = false;//是否需要搜索附件poi
    private MapView mapView;
    private RelativeLayout mapViewLayout;
    private OnLocationChangedListener mListener;
    private AMapLocationClient mlocationClient;
    private AMapLocationClientOption mLocationOption;
    private ImageButton btn_gps_location;

    private LocationManager locationManager;
    String[] locationPermissions = new String[]{Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_LOCATION_EXTRA_COMMANDS};
    private Button cancelBtn;
    private Button sendBtn;
    private AMap aMap;
    private RelativeLayout bottomLayout;
    private SmartRefreshLayout mSmartRefreshLayout;
    private EditText mSearchView;
    private TextView searchCancel;
    private NSDrawerLayout mDrawerLayout;
    private int mDrawerOpenOffSet = 0;  //抽屉打开的距离
    private int mDrawerCloseOffSet = 0;  //抽屉关闭的距离

    private NSRecyclerAdapter mAdapter;




    private NSRecyclerAdapter.NSRecyclerItemClickListener adapterClickListener = new NSRecyclerAdapter.NSRecyclerItemClickListener() {
        @Override
        public void onItemClicked(int position, PoiItemV2 poiItemV2) {

            LatLng latLng;
            if (position == 0 && mAdapter.resultType == NSRecyclerAdapter.NSRecyclerAdapterResultType.normalType) {
                latLng = new LatLng(mAdapter.normalPOILocation.getLatitude(), mAdapter.normalPOILocation.getLongitude());
            } else {
                latLng = new LatLng(poiItemV2.getLatLonPoint().getLatitude(), poiItemV2.getLatLonPoint().getLongitude());

            }
            if (mAdapter.resultType == NSRecyclerAdapter.NSRecyclerAdapterResultType.keywordType) {
                addKeywordPointMaker(latLng);
            }
            aMap.animateCamera(CameraUpdateFactory.newLatLngZoom(latLng, 17f));
            needSearchNearbyPOI = false;

        }

        @Override
        public void showResultTypeChanged(NSRecyclerAdapter.NSRecyclerAdapterResultType type) {
            if (type == NSRecyclerAdapter.NSRecyclerAdapterResultType.keywordType) {
                if (screenMarker != null) {
                    screenMarker.remove();
                    screenMarker = null;
                }

            } else {
                if (keywordPointMaker != null) {
                    keywordPointMaker.remove();
                    keywordPointMaker = null;
                }
                addMarkerInScreenCenter();
            }
        }

        @Override
        public void selectedPOIChanged(PoiItemV2 selectedPOI) {
            if (selectedPOI == null) {
                sendBtn.setEnabled(false);
            } else {
                sendBtn.setEnabled(true);
            }
        }
    };

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_map_location);

        //状态栏沉浸
        NSStatusBarUtil.setTranslucentStatus(this, true);
        Intent getIntent = getIntent();
        Bundle bundle = getIntent.getBundleExtra("param");
        if (bundle != null) {
            param = (NSMapLocationParam) bundle.getSerializable("param");
        } else {
            param = new NSMapLocationParam();
        }
        initView(savedInstanceState);
        initData();

        checkLocationPermission();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mapView.onDestroy();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
    }

    @Override
    protected void onResume() {
        super.onResume();
        mapView.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        mapView.onPause();
    }

    private void initView(Bundle savedInstanceState) {
        mapView = findViewById(R.id.map_view);
        mapView.onCreate(savedInstanceState);

        RecyclerView mRecyclerView = findViewById(R.id.list_view);
        mapViewLayout = findViewById(R.id.map_view_layout);
        bottomLayout = findViewById(R.id.bottom_layout);
        mSmartRefreshLayout = findViewById(R.id.smart_refresh);
        mDrawerLayout = findViewById(R.id.scroll_down_layout);
        mSearchView = findViewById(R.id.search_view);
        searchCancel = findViewById(R.id.search_cancel);
        sendBtn = findViewById(R.id.location_btn_send);
        cancelBtn = findViewById(R.id.location_btn_cancel);
        btn_gps_location = findViewById(R.id.location_btn);


        mRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        mAdapter = new NSRecyclerAdapter(this, adapterClickListener);

        mRecyclerView.setAdapter(mAdapter);
        mapView.setOnClickListener(this);
        searchCancel.setOnClickListener(this);
        sendBtn.setOnClickListener(this);
        cancelBtn.setOnClickListener(this);
        btn_gps_location.setOnClickListener(this);


        if (aMap == null) {
            aMap = mapView.getMap();
            setUpMap();
        }

    }

    /**
     * 设置一些amap的属性
     */
    private void setUpMap() {
        MyLocationStyle myLocationStyle = new MyLocationStyle();
        myLocationStyle.anchor(0.5f, 0.5f);
        myLocationStyle.myLocationIcon(BitmapDescriptorFactory.fromResource(R.drawable.img_gps_location));
        myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATE);
        aMap.setMyLocationStyle(myLocationStyle);
        aMap.getUiSettings().setLogoBottomMargin((int) (NSViewUtil.getScreenHeight(NSMapLocationActivity.this) * 0.7) + NSViewUtil.dip2px(NSMapLocationActivity.this, 15));
        aMap.getUiSettings().setZoomControlsEnabled(false);
        aMap.getUiSettings().setAllGesturesEnabled(false);
        aMap.getUiSettings().setLogoPosition(AMapOptions.LOGO_POSITION_BOTTOM_RIGHT);
        aMap.setLocationSource(this);// 设置定位监听
//        aMap.getUiSettings().setMyLocationButtonEnabled(true);// 设置默认定位按钮是否显示
        aMap.setMyLocationEnabled(true);// 设置为true表示显示定位层并可触发定位，false表示隐藏定位层并不可触发定位，默认是false
        aMap.setOnCameraChangeListener(this);// 对amap添加移动地图事件监听器

        aMap.setOnMapClickListener(this);
        aMap.setOnPOIClickListener(this);
    }

    //始终固定在屏幕中心位置的点
    private void addMarkerInScreenCenter() {

        if (screenMarker == null) {
            screenMarker = aMap.addMarker(new MarkerOptions().zIndex(20)
                    .icon(BitmapDescriptorFactory.fromResource(R.drawable.img_map_center_wateredblank)));
        }
        screenMarker.setAnchor(0.5f, 1.0f);
        LatLng latLng = aMap.getCameraPosition().target;
        Point screenPosition = aMap.getProjection().toScreenLocation(latLng);

        screenMarker.setPositionByPixels(screenPosition.x, screenPosition.y);
        screenMarker.setClickable(false);
    }

    private void addKeywordPointMaker(LatLng latLng) {
        if (keywordPointMaker != null) {
            keywordPointMaker.remove();
        }
        keywordPointMaker = aMap.addMarker(new MarkerOptions().position(latLng).icon(BitmapDescriptorFactory.fromResource(R.drawable.img_map_center_wateredblank)));
        keywordPointMaker.setAnchor(0.5f, 1.0f);
    }

    private void initData() {
        mDrawerOpenOffSet = (int) (NSViewUtil.getScreenHeight(this) * 0.7);
        mDrawerCloseOffSet = (int) (NSViewUtil.getScreenHeight(this) * 0.3);
        LayoutParams params = (LayoutParams) mapViewLayout.getLayoutParams();
        params.height = mDrawerOpenOffSet;
        params.width = NSViewUtil.getScreenWidth(this);
        mapViewLayout.setLayoutParams(params);
        mSmartRefreshLayout.setEnableRefresh(false);
        mSmartRefreshLayout.setEnableLoadMore(true);
        mSmartRefreshLayout.setRefreshFooter(new ClassicsFooter(this));
        mDrawerLayout.setMinOffset(mDrawerCloseOffSet);
        mDrawerLayout.setMaxOffset(mDrawerCloseOffSet);
        mDrawerLayout.setExitOffset(mDrawerCloseOffSet);
        mDrawerLayout.setIsSupportExit(false);
        mDrawerLayout.setOnScrollChangedListener(mOnScrollChangedListener);
        mDrawerLayout.setToOpen();
        mSmartRefreshLayout.setOnLoadMoreListener(refreshLayout -> {

            if (mAdapter.resultType == NSRecyclerAdapter.NSRecyclerAdapterResultType.normalType) {
                mAdapter.normalTypePage++;
                startSearchPoiWithLatLonPoint(mAdapter.normalPOILocation, mAdapter.normalTypePage);
            } else {
                mAdapter.keywordTypePage++;
                startSearchPoiWithKeyword(mSearchView.getText().toString(), mAdapter.keywordTypePage);
            }
        });
        mSearchView.setOnTouchListener((view, motionEvent) -> {
            if (motionEvent.getAction() == MotionEvent.ACTION_UP) {
                mDrawerLayout.setToClosed();
                searchCancel.setVisibility(View.VISIBLE);
                mAdapter.setResultType(NSRecyclerAdapter.NSRecyclerAdapterResultType.keywordType);
            }

            return false;
        });
        mSearchView.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_SEARCH){
                    hiddeKeyboard(mSearchView.getWindowToken());
                }
                return false;
            }
        });
        mSearchView.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void afterTextChanged(Editable editable) {
                // 输入后的监听
                Log.d("xxx", editable.toString());
                mAdapter.clearAllKeywordData();
                if (editable.toString().length() > 0) {
                    startSearchPoiWithKeyword(editable.toString(), mAdapter.keywordTypePage);
                }


            }
        });
    }


    private final NSDrawerLayout.OnScrollChangedListener mOnScrollChangedListener = new NSDrawerLayout.OnScrollChangedListener() {
        @Override
        public void onScrollProgressChanged(float currentProgress) {
            //底部地图滑动距离为当前位置距离顶部高度(抽屉关闭高度)的一半
            float maxOffSet = (float) (mDrawerOpenOffSet - mDrawerCloseOffSet) / 2;
            mapViewLayout.scrollTo(0, (int) (maxOffSet * (1 - currentProgress)));
            bottomLayout.scrollTo(0, (int) (maxOffSet * (1 - currentProgress)));

            aMap.getUiSettings().setLogoBottomMargin((int) (maxOffSet * (1 - currentProgress) + NSViewUtil.dip2px(NSMapLocationActivity.this, 15)));

            aMap.getUiSettings().setLogoLeftMargin(NSViewUtil.getScreenWidth(NSMapLocationActivity.this) - NSViewUtil.dip2px(NSMapLocationActivity.this, 100));

        }

        @Override
        public void onScrollFinished(Status currentStatus) {
            if (currentStatus == Status.OPENED || currentStatus == Status.EXIT) {
                searchCancel.setVisibility(View.GONE);
                hiddeKeyboard(mSearchView.getWindowToken());
            }
        }

        @Override
        public void onChildScroll(int top) {

        }
    };

    @Override
    public void onClick(View view) {
        if (view == mapView) {
            hiddeKeyboard(mSearchView.getWindowToken());
            mDrawerLayout.setToOpen();
        } else if (view == searchCancel) {
            hiddeKeyboard(mSearchView.getWindowToken());
            mSearchView.clearFocus();
            mSearchView.setText("");
            searchCancel.setVisibility(View.GONE);
            mDrawerLayout.setToOpen();
            mAdapter.clearAllKeywordData();
            mAdapter.setResultType(NSRecyclerAdapter.NSRecyclerAdapterResultType.normalType);

        } else if (view == btn_gps_location) {

            if (checkLocationPermission()) {
                if (btn_gps_location.isSelected()) {
                    return;
                }
                if (mAdapter.gpsLocation == null) {
                    aMap.getUiSettings().setAllGesturesEnabled(false);
                    isLocated = false;
                    mlocationClient.startLocation();
                } else {
                    btn_gps_location.setSelected(true);
                    aMap.animateCamera(CameraUpdateFactory.newLatLngZoom(mAdapter.gpsLocation, 17f));
                }
            }


        } else if (view == cancelBtn) {
            try {
                Intent intent = new Intent();
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("errCode", -3);
                jsonObject.put("errorMsg", "用户取消了");
                intent.putExtra("data", jsonObject.toString());
                setResult(RESULT_OK, intent);
            } catch (JSONException e) {
                throw new RuntimeException(e);
            }
            finish();
        } else if (view == sendBtn) {

            PoiItemV2 currentPoi = mAdapter.getCurrentPoi();
            try {
                Intent intent = new Intent();
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("errCode", 0);
                jsonObject.put("address", currentPoi.getSnippet());
                jsonObject.put("name", currentPoi.getTitle());
                jsonObject.put("province", currentPoi.getProvinceName());
                jsonObject.put("city", currentPoi.getCityName());
                jsonObject.put("district", currentPoi.getAdName());
                jsonObject.put("businessArea", currentPoi.getBusiness().getBusinessArea());
                jsonObject.put("latitude", currentPoi.getLatLonPoint().getLatitude());
                jsonObject.put("longitude", currentPoi.getLatLonPoint().getLongitude());
                jsonObject.put("errorMsg", "获取成功");
                intent.putExtra("data", jsonObject.toString());
                setResult(RESULT_OK, intent);
            } catch (JSONException e) {
                throw new RuntimeException(e);
            }

            finish();

        }
    }


    /**
     * 输入框以外的部分关闭软键盘
     *
     * @param ev
     * @return
     */
    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (ev.getAction() == MotionEvent.ACTION_DOWN) {
            // 获得当前得到焦点的View，
            View v = getCurrentFocus();
            if (isShouldHideInput(v, ev)) {
                hiddeKeyboard(v.getWindowToken());
            }
        }
        return super.dispatchTouchEvent(ev);
    }

    private boolean isShouldHideInput(View v, MotionEvent event) {
        if ((v instanceof EditText)) {
            int[] l = {0, 0};
            v.getLocationInWindow(l);
            int left = l[0], top = l[1], bottom = top + v.getHeight(), right = left
                    + v.getWidth();
            if (event.getX() > left && event.getX() < right
                    && event.getY() > top && event.getY() < bottom) {
                // 点击EditText的事件，忽略它。
                return false;
            } else {
                return true;
            }
        }
        return false;
    }

    /**
     * 隐藏键盘
     *
     * @param mSearchView
     */
    private void hiddeKeyboard(IBinder mSearchView) {
        InputMethodManager imm = (InputMethodManager) getSystemService(
                Context.INPUT_METHOD_SERVICE);
        if (null != imm) {
            imm.hideSoftInputFromWindow(mSearchView, 0);
        }
    }

    @Override
    public void activate(OnLocationChangedListener listener) {
        mListener = listener;
        if (mlocationClient == null) {
            try {
                mlocationClient = new AMapLocationClient(this);
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
            mLocationOption = new AMapLocationClientOption();
            mLocationOption.setOnceLocation(true);
            //设置定位监听
            mlocationClient.setLocationListener(this);
            //设置为高精度定位模式
            mLocationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.Hight_Accuracy);
            //设置定位参数

            mlocationClient.setLocationOption(mLocationOption);
            // 此方法为每隔固定时间会发起一次定位请求，为了减少电量消耗或网络流量消耗，
            // 注意设置合适的定位时间的间隔（最小间隔支持为2000ms），并且在合适时间调用stopLocation()方法来取消定位请求
            // 在定位结束后，在合适的生命周期调用onDestroy()方法
            // 在单次定位情况下，定位无论成功与否，都无需调用stopLocation()方法移除请求，定位sdk内部会移除
            mlocationClient.startLocation();
        }
    }

    @Override
    public void deactivate() {
        mListener = null;
        if (mlocationClient != null) {
            mlocationClient.stopLocation();
            mlocationClient.onDestroy();
        }
        mlocationClient = null;

    }

    @Override
    public void onLocationChanged(AMapLocation amapLocation) {
        if (mListener != null && amapLocation != null) {
            if (amapLocation != null
                    && amapLocation.getErrorCode() == 0) {

                if (isLocated == false) {
                    isLocated = true;
                    mAdapter.gpsLocation = new LatLng(amapLocation.getLatitude(), amapLocation.getLongitude());
                    mAdapter.normalPOILocation = new LatLonPoint(amapLocation.getLatitude(), amapLocation.getLongitude());

                    mAdapter.clearAllData();
                    startSearchPoiWithLatLonPoint(new LatLonPoint(mAdapter.gpsLocation.latitude, mAdapter.gpsLocation.longitude), mAdapter.normalTypePage);
                    // 显示系统小蓝点
                    mListener.onLocationChanged(amapLocation);
                    aMap.moveCamera(CameraUpdateFactory.zoomTo(17));

                    if (mAdapter.resultType == NSRecyclerAdapter.NSRecyclerAdapterResultType.normalType) {
                        new Handler().postDelayed(new Runnable() {
                            @Override
                            public void run() {

                                // TODO
                                addMarkerInScreenCenter();
                            }
                        }, 500);
                    }
                }

            } else {
                String errText = "定位失败," + amapLocation.getErrorCode() + ": " + amapLocation.getErrorInfo();
                Log.e("AmapErr", errText);
            }
        }
    }

    @Override
    public void onCameraChange(CameraPosition cameraPosition) {
    }

    @Override
    public void onCameraChangeFinish(CameraPosition cameraPosition) {


        if(mAdapter.gpsLocation == null){
            btn_gps_location.setSelected(false);
        }
        else{
            float distance = AMapUtils.calculateLineDistance(new LatLng(cameraPosition.target.latitude, cameraPosition.target.longitude), mAdapter.gpsLocation);
            if (distance < 5) {
                btn_gps_location.setSelected(true);
            } else {
                btn_gps_location.setSelected(false);
            }
        }

        if (!aMap.getUiSettings().isScrollGesturesEnabled()) {
            return;
        }

        if (needSearchNearbyPOI && mAdapter.resultType == NSRecyclerAdapter.NSRecyclerAdapterResultType.normalType) {
            mAdapter.clearAllData();
            LatLonPoint latLng = new LatLonPoint(cameraPosition.target.latitude, cameraPosition.target.longitude);
            mAdapter.normalPOILocation = latLng;
            startSearchPoiWithLatLonPoint(latLng, mAdapter.normalTypePage);
        }

        needSearchNearbyPOI = true;
    }

    @Override
    public void onMapClick(LatLng latLng) {

        Log.d("xxx", "onMapClick");
        hiddeKeyboard(mSearchView.getWindowToken());
        mDrawerLayout.setToOpen();
    }

    @Override
    public void onPOIClick(Poi poi) {
        Log.d("xxx", "onPOIClick");
        if (mAdapter.resultType == NSRecyclerAdapter.NSRecyclerAdapterResultType.normalType) {
            aMap.animateCamera(CameraUpdateFactory.newLatLngZoom(poi.getCoordinate(), 17f));
        }

    }


    void startSearchPoiWithLatLonPoint(LatLonPoint amapLocation, int page) {

        try {
            Query poiQuery = new Query("", param.getTypes(), param.city);
            poiQuery.setPageSize(20);// 设置每页最多返回多少条poiitem
            poiQuery.setPageNum(page);//设置查询页码
            poiQuery.setCityLimit(param.cityLimit);
            PoiSearchV2 poiSearch = null;
            poiSearch = new PoiSearchV2(this, poiQuery);

            poiSearch.setOnPoiSearchListener(this);
            poiSearch.setBound(new PoiSearchV2.SearchBound(amapLocation, param.radius));//设置周边搜索的中心点以及半径
            poiSearch.searchPOIAsyn();
        } catch (AMapException e) {
            throw new RuntimeException(e);
        }

    }

    void startSearchPoiWithKeyword(String keyword, int page) {

        try {
            Query poiQuery = new Query(keyword, param.getTypes(), param.city);
            poiQuery.setPageSize(20);// 设置每页最多返回多少条poiitem
            poiQuery.setPageNum(page);//设置查询页码
            poiQuery.setCityLimit(param.cityLimit);
            PoiSearchV2 poiSearch = null;
            poiSearch = new PoiSearchV2(this, poiQuery);

            poiSearch.setOnPoiSearchListener(this);
            if (param.searchType != NSMapLocationParam.NSMapLocationSearchTypeKeyWord && mAdapter.gpsLocation != null) {
                poiSearch.setBound(new PoiSearchV2.SearchBound(new LatLonPoint(mAdapter.gpsLocation.latitude, mAdapter.gpsLocation.longitude), param.radius));//设置周边搜索的中心点以及半径
            }

            poiSearch.searchPOIAsyn();
        } catch (AMapException e) {
            throw new RuntimeException(e);
        }

    }

    @Override
    public void onPoiSearched(PoiResultV2 poiResultV2, int i) {

        needSearchNearbyPOI = true;
        aMap.getUiSettings().setAllGesturesEnabled(true);

        if (poiResultV2.getPois().size() != 0) {
            if (mAdapter.resultType == NSRecyclerAdapter.NSRecyclerAdapterResultType.normalType) {
                mAdapter.addData(poiResultV2.getPois());
            } else {
                mAdapter.addKeywordData(poiResultV2.getPois());
            }
            mSmartRefreshLayout.finishLoadMore(true);
        } else {
            if (mAdapter.resultType != NSRecyclerAdapter.NSRecyclerAdapterResultType.normalType && poiResultV2.getQuery().getPageNum() == 1 && param.searchType == NSMapLocationParam.NSMapLocationSearchTypeKeyAuto && poiResultV2.getBound() != null) {
                try {
                    Query poiQuery = new Query(poiResultV2.getQuery().getQueryString(), param.getTypes(), param.city);
                    poiQuery.setPageSize(20);// 设置每页最多返回多少条poiitem
                    poiQuery.setPageNum(1);//设置查询页码
                    poiQuery.setCityLimit(param.cityLimit);
                    PoiSearchV2 poiSearch = null;
                    poiSearch = new PoiSearchV2(this, poiQuery);
                    poiSearch.setOnPoiSearchListener(this);
                    poiSearch.searchPOIAsyn();

                } catch (AMapException e) {
                    throw new RuntimeException(e);

                }


            } else {
                mSmartRefreshLayout.finishLoadMore(false);
            }

        }

    }

    @Override
    public void onPoiItemSearched(PoiItemV2 poiItemV2, int i) {

    }

    boolean checkLocationPermission() {
        if (lacksPermission(locationPermissions)) {

            String message = "请在「位置」中允许" + NSAppUtil.getAppName() + "在「使用APP期间」访问位置信息。";
            new AlertDialog.Builder(this).setTitle("无法获取你的位置信息").setMessage(message).setPositiveButton("去设置", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).setData(Uri.fromParts("package", getPackageName(), null));
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    startActivity(intent);
                }
            }).setNegativeButton("取消", null).show();
            return false;
        }
        return true;
    }

    //如果返回true表示缺少权限
    public boolean lacksPermission(String[] permissions) {
        for (String permission : permissions) {
            //判断是否缺少权限，true=缺少权限
            if (ContextCompat.checkSelfPermission(getApplicationContext(), permission) != PackageManager.PERMISSION_GRANTED) {
                return true;
            }
        }
        return false;
    }
}
