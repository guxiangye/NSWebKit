package com.nswebkit.plugins.scan.scan.other;

import android.graphics.Bitmap;

import com.google.zxing.Result;

/**
 * @author : maning
 * @date : 2020-09-09
 * @desc :
 */
public interface OnScanCallback {

    /**
     * 扫码成功
     * @param rawResult
     * @param barcode
     */
    void onScanSuccess(Result[] rawResult, Bitmap barcode);

    /**
     * 暂停扫描
     */
    void onStopScan();

    /**
     * 重新扫描
     */
    void onRestartScan();

    /**
     * 失败
     * @param msg
     */
    void onFail(String msg);

}
