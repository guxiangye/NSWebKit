/*
 * Copyright (C) 2010 ZXing authors
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

import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.Log;

import com.google.zxing.BinaryBitmap;
import com.google.zxing.DecodeHintType;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.PlanarYUVLuminanceSource;
import com.google.zxing.Result;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.multi.qrcode.QRCodeMultiReader;
import com.nswebkit.plugins.scan.R;
import com.nswebkit.plugins.scan.scan.model.MNScanConfig;
import com.nswebkit.plugins.scan.scan.view.ScanSurfaceView;

import java.io.ByteArrayOutputStream;
import java.lang.ref.WeakReference;
import java.util.Map;

public class DecodeHandler extends Handler {

    private static final String TAG = DecodeHandler.class.getSimpleName();

    private WeakReference<ScanSurfaceView> mSurfaceViewRef;
    private boolean running = true;
    private MultiFormatReader multiFormatReader;
    private QRCodeMultiReader qrCodeMultiReader;
    private Map<DecodeHintType, Object> hints;
    //支持同时扫描多个二维码
    private boolean supportMultiQRCode = false;

    public DecodeHandler(WeakReference<ScanSurfaceView> mSurfaceViewRef, Map<DecodeHintType, Object> hints) {
        this.hints = hints;
        if (mSurfaceViewRef.get() != null) {
            MNScanConfig scanConfig = mSurfaceViewRef.get().getScanConfig();
            if (scanConfig != null) {
                supportMultiQRCode = scanConfig.isSupportMultiQRCode();
            }
        }
        if (supportMultiQRCode) {
            //支持多个二维码，但是不支持条形码
            qrCodeMultiReader = new QRCodeMultiReader();
        } else {
            //单个二维码
            multiFormatReader = new MultiFormatReader();
            multiFormatReader.setHints(hints);
        }
        this.mSurfaceViewRef = mSurfaceViewRef;
    }

    @Override
    public void handleMessage(Message message) {
        if (message == null || !running) {
            return;
        }
        if (message.what == R.id.decode) {
            decode((byte[]) message.obj, message.arg1, message.arg2);

        } else if (message.what == R.id.quit) {
            running = false;
            Looper.myLooper().quit();

        }
    }

    /**
     * Decode the data within the viewfinder rectangle, and time how long it took. For efficiency,
     * reuse the same reader objects from one decode to the next.
     *
     * @param data   The YUV preview frame.
     * @param width  The width of the preview frame.
     * @param height The height of the preview frame.
     */
    private void decode(byte[] data, int width, int height) {
        //1080*2248 小米8：1264*2248
        //1080*2160 魅族16X：960*1920
        Log.e(TAG, "decode---width：" + width + "，height" + height);
        long start = System.currentTimeMillis();

        //2017.11.13 添加竖屏代码处理，生成正确方向图片
        if (width < height) {
            // portrait
            byte[] rotatedData = new byte[data.length];
            for (int x = 0; x < width; x++) {
                for (int y = 0; y < height; y++) {
                    rotatedData[y * width + width - x - 1] = data[y + x * height];
                }

            }
            data = rotatedData;
        }
        ScanSurfaceView scanSurfaceView = mSurfaceViewRef.get();
        if (scanSurfaceView == null) {
            return;
        }
        Result[] rawResults = null;
        PlanarYUVLuminanceSource source = scanSurfaceView.getCameraManager().buildLuminanceSource(data, width, height);
        if (source != null) {
            BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));
            try {
                if (supportMultiQRCode) {
                    rawResults = qrCodeMultiReader.decodeMultiple(bitmap);
                } else {
                    Result[] results = new Result[1];
                    Result result = multiFormatReader.decodeWithState(bitmap);
                    results[0] = result;
                    rawResults = results;
                }
            } catch (Exception re) {
                // continue
            } finally {
                if (supportMultiQRCode) {
                    qrCodeMultiReader.reset();
                } else {
                    multiFormatReader.reset();
                }
            }
        }

        Handler handler = scanSurfaceView.getCaptureHandler();
        if (rawResults != null && rawResults.length > 0) {
            // Don't log the barcode contents for security.
            long end = System.currentTimeMillis();
            Log.d(TAG, "Found barcode in " + (end - start) + " ms");
            if (handler != null) {
                Message message = Message.obtain(handler, R.id.decode_succeeded, rawResults);
                Bundle bundle = new Bundle();
                bundleThumbnail(source, bundle);
                message.setData(bundle);
                message.sendToTarget();
            }
        } else {
            if (handler != null) {
                Message message = Message.obtain(handler, R.id.decode_failed);
                message.sendToTarget();
            }
        }
    }

    private static void bundleThumbnail(PlanarYUVLuminanceSource source, Bundle bundle) {
        int[] pixels = source.renderThumbnail();
        int width = source.getThumbnailWidth();
        int height = source.getThumbnailHeight();
        Bitmap bitmap = Bitmap.createBitmap(pixels, 0, width, width, height, Bitmap.Config.ARGB_8888);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 50, out);
        bundle.putByteArray(DecodeThread.BARCODE_BITMAP, out.toByteArray());
        bundle.putFloat(DecodeThread.BARCODE_SCALED_FACTOR, (float) width / source.getWidth());
    }

}
