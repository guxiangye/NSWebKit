/*
 * Copyright (C) 2008 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.nswebkit.plugins.scan.scan.decode;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.DecodeHintType;
import com.google.zxing.ResultPointCallback;
import com.nswebkit.plugins.scan.scan.model.MNScanConfig;
import com.nswebkit.plugins.scan.scan.view.ScanSurfaceView;

import java.lang.ref.WeakReference;
import java.util.Collection;
import java.util.EnumMap;
import java.util.Map;
import java.util.Vector;
import java.util.concurrent.CountDownLatch;

/**
 * This thread does all the heavy lifting of decoding the images.
 *
 * @author dswitkin@google.com (Daniel Switkin)
 */
public class DecodeThread extends Thread {

    public static final String BARCODE_BITMAP = "barcode_bitmap";
    public static final String BARCODE_SCALED_FACTOR = "barcode_scaled_factor";

    private final Map<DecodeHintType, Object> hints;
    private Handler handler;
    private final CountDownLatch handlerInitLatch;
    private WeakReference<ScanSurfaceView> mSurfaceViewRef;

    public DecodeThread(ScanSurfaceView surfaceView,
                        Collection<BarcodeFormat> decodeFormats,
                        Map<DecodeHintType, ?> baseHints,
                        String characterSet,
                        ResultPointCallback resultPointCallback, MNScanConfig scanConfig) {

        mSurfaceViewRef = new WeakReference<ScanSurfaceView>(surfaceView);
        handlerInitLatch = new CountDownLatch(1);

        hints = new EnumMap<>(DecodeHintType.class);
        if (baseHints != null) {
            hints.putAll(baseHints);
        }

        if (decodeFormats == null || decodeFormats.isEmpty()) {
            decodeFormats = new Vector<BarcodeFormat>();
            // 扫描的类型:一维码和二维码
            if (scanConfig.getSupportCode() == 1) {
                decodeFormats.addAll(DecodeFormatManager.QR_CODE_FORMATS);
            } else if (scanConfig.getSupportCode() == 2) {
                decodeFormats.addAll(DecodeFormatManager.ONE_D_FORMATS);
            } else {
                decodeFormats.addAll(DecodeFormatManager.ONE_D_FORMATS);
                decodeFormats.addAll(DecodeFormatManager.QR_CODE_FORMATS);
            }
            decodeFormats.addAll(DecodeFormatManager.DATA_MATRIX_FORMATS);
            decodeFormats.addAll(DecodeFormatManager.AZTEC_FORMATS);
            decodeFormats.addAll(DecodeFormatManager.PDF417_FORMATS);
        }
        hints.put(DecodeHintType.POSSIBLE_FORMATS, decodeFormats);

        if (characterSet != null) {
            hints.put(DecodeHintType.CHARACTER_SET, characterSet);
        }
        hints.put(DecodeHintType.NEED_RESULT_POINT_CALLBACK, resultPointCallback);
        Log.i("DecodeThread", "Hints: " + hints);
    }

    public Handler getHandler() {
        try {
            handlerInitLatch.await();
        } catch (InterruptedException ie) {
            // continue?
        }
        return handler;
    }

    @Override
    public void run() {
        Looper.prepare();
        handler = new DecodeHandler(mSurfaceViewRef, hints);
        handlerInitLatch.countDown();
        Looper.loop();
    }

    public void destroyView() {
        mSurfaceViewRef = null;
        handler.removeCallbacksAndMessages(null);
        handler = null;
    }

}
