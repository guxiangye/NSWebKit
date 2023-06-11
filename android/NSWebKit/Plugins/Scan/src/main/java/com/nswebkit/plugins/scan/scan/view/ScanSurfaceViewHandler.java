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

package com.nswebkit.plugins.scan.scan.view;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.DecodeHintType;
import com.google.zxing.Result;
import com.nswebkit.plugins.scan.R;
import com.nswebkit.plugins.scan.scan.camera.CameraManager;
import com.nswebkit.plugins.scan.scan.decode.DecodeThread;
import com.nswebkit.plugins.scan.scan.model.MNScanConfig;

import java.util.Collection;
import java.util.Map;

/**
 * This class handles all the messaging which comprises the state machine for mn_scan_capture.
 *
 * @author dswitkin@google.com (Daniel Switkin)
 */
public final class ScanSurfaceViewHandler extends Handler {

    private DecodeThread decodeThread;
    private State state;
    private CameraManager cameraManager;
    private ScanSurfaceView scanSurfaceView;

    private enum State {
        PREVIEW,
        SUCCESS,
        DONE
    }

    public ScanSurfaceViewHandler(ScanSurfaceView scanSurfaceView,
                                  Collection<BarcodeFormat> decodeFormats,
                                  Map<DecodeHintType, ?> baseHints,
                                  String characterSet,
                                  CameraManager cameraManager, MNScanConfig scanConfig) {
        this.scanSurfaceView = scanSurfaceView;
        decodeThread = new DecodeThread(scanSurfaceView, decodeFormats, baseHints, characterSet,
                null,scanConfig);
        decodeThread.start();
        state = State.SUCCESS;

        // Start ourselves capturing previews and decoding.
        this.cameraManager = cameraManager;
        cameraManager.startPreview();
        restartPreviewAndDecode();
    }

    @Override
    public void handleMessage(Message message) {
        if (message.what == R.id.restart_preview) {
            restartPreviewAndDecode();
        } else if (message.what == R.id.decode_succeeded) {
            state = State.SUCCESS;
            Bundle bundle = message.getData();
            Bitmap barcode = null;
            float scaleFactor = 1.0f;
            if (bundle != null) {
                byte[] compressedBitmap = bundle.getByteArray(DecodeThread.BARCODE_BITMAP);
                if (compressedBitmap != null) {
                    barcode = BitmapFactory.decodeByteArray(compressedBitmap, 0, compressedBitmap.length, null);
                    // Mutable copy:
                    barcode = barcode.copy(Bitmap.Config.ARGB_8888, true);
                }
                scaleFactor = bundle.getFloat(DecodeThread.BARCODE_SCALED_FACTOR);
            }
            scanSurfaceView.handleDecode((Result[]) message.obj, barcode, scaleFactor);
            restartPreviewAndDecode();
        } else if (message.what == R.id.decode_failed) {// We're decoding as fast as possible, so when one decode fails, start another.
            state = State.PREVIEW;
            cameraManager.requestPreviewFrame(decodeThread.getHandler(), R.id.decode);
        }
    }

    public void quitSynchronously() {
        state = State.DONE;
        cameraManager.stopPreview();
        Message quit = Message.obtain(decodeThread.getHandler(), R.id.quit);
        quit.sendToTarget();
        try {
            // Wait at most half a second; should be enough time, and onPause() will timeout quickly
            decodeThread.join(500L);
        } catch (InterruptedException e) {
            // continue
        }

        // Be absolutely sure we don't send any queued up messages
        removeMessages(R.id.decode_succeeded);
        removeMessages(R.id.decode_failed);
    }

    private void restartPreviewAndDecode() {
        if (state == State.SUCCESS) {
            state = State.PREVIEW;
            cameraManager.requestPreviewFrame(decodeThread.getHandler(), R.id.decode);
            scanSurfaceView.getViewfinderView().drawViewfinder();
        }
    }

    public void destroyView() {
        removeCallbacksAndMessages(null);
        scanSurfaceView = null;
        decodeThread.destroyView();
        decodeThread = null;
    }

}
