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

package com.nswebkit.plugins.scan.scan.camera;

import android.content.Context;
import android.graphics.Point;
import android.graphics.Rect;
import android.hardware.Camera;
import android.os.Handler;
import android.util.Log;
import android.view.SurfaceHolder;

import com.google.zxing.PlanarYUVLuminanceSource;
import com.nswebkit.plugins.scan.scan.camera.open.OpenCamera;
import com.nswebkit.plugins.scan.scan.camera.open.OpenCameraInterface;
import com.nswebkit.plugins.scan.scan.view.ResizeAbleSurfaceView;
import com.nswebkit.plugins.scan.scan.view.ScanSurfaceView;

import java.io.IOException;

/**
 * This object wraps the Camera service object and expects to be the only one talking to it. The
 * implementation encapsulates the steps needed to take preview-sized images, which are used for
 * both preview and decoding.
 *
 * @author dswitkin@google.com (Daniel Switkin)
 */
public class CameraManager {

    private static final String TAG = CameraManager.class.getSimpleName();

    private static int MIN_FRAME_WIDTH = 240;
    private static int MIN_FRAME_HEIGHT = 240;
    private static int MAX_FRAME_WIDTH = 800;
    private static int MAX_FRAME_HEIGHT = 800; // = 5/8 * 1080

    private final Context context;
    private final CameraConfigurationManager configManager;
    private OpenCamera camera;
    private AutoFocusManager autoFocusManager;
    private Rect framingRect;
    private Rect framingRectInPreview;
    private boolean initialized;
    private boolean previewing;
    private int requestedCameraId = OpenCameraInterface.NO_REQUESTED_CAMERA;
    private int requestedFramingRectWidth;
    private int requestedFramingRectHeight;
    /**
     * Preview frames are delivered here, which we pass on to the registered handler. Make sure to
     * clear the handler so it will only receive one message.
     */
    private final PreviewCallback previewCallback;

    public CameraManager(Context context) {
        this.context = context;
        this.configManager = new CameraConfigurationManager(context);
        previewCallback = new PreviewCallback(configManager);
    }

    /**
     * Opens the camera driver and initializes the hardware parameters.
     *
     * @param holder The surface object which the camera will draw preview frames into.
     * @throws IOException Indicates the camera driver failed to open.
     */
    public synchronized void openDriver(SurfaceHolder holder, ResizeAbleSurfaceView surfaceView) throws IOException {
        OpenCamera theCamera = camera;
        if (theCamera == null) {
            theCamera = OpenCameraInterface.open(requestedCameraId);
            if (theCamera == null) {
                throw new IOException("Camera.open() failed to return object from driver");
            }
            camera = theCamera;
        }

        if (!initialized) {
            initialized = true;
            configManager.initFromCameraParameters(theCamera, surfaceView);
            if (requestedFramingRectWidth > 0 && requestedFramingRectHeight > 0) {
                setManualFramingRect(requestedFramingRectWidth, requestedFramingRectHeight);
                requestedFramingRectWidth = 0;
                requestedFramingRectHeight = 0;
            }
        }

        Camera cameraObject = theCamera.getCamera();
        Camera.Parameters parameters = cameraObject.getParameters();
        String parametersFlattened = parameters == null ? null : parameters.flatten(); // Save these, temporarily
        try {
            configManager.setDesiredCameraParameters(theCamera, false);
        } catch (RuntimeException re) {
            // Driver failed
            Log.w(TAG, "Camera rejected parameters. Setting only minimal safe-mode parameters");
            Log.i(TAG, "Resetting to saved camera params: " + parametersFlattened);
            // Reset:
            if (parametersFlattened != null) {
                parameters = cameraObject.getParameters();
                parameters.unflatten(parametersFlattened);
                try {
                    cameraObject.setParameters(parameters);
                    configManager.setDesiredCameraParameters(theCamera, true);
                } catch (RuntimeException re2) {
                    // Well, darn. Give up
                    Log.w(TAG, "Camera rejected even safe-mode parameters! No configuration");
                }
            }
        }
        cameraObject.setPreviewDisplay(holder);

        //重新设置相机预览大小
        Point previewSizeOnScreen = configManager.getPreviewSizeOnScreen();
        int surfaceViewHeightDefault = surfaceView.getHeight();
        int surfaceViewWidthDefault = surfaceView.getWidth();
        int width = previewSizeOnScreen.x;
        int height = previewSizeOnScreen.y;

        int surfaceViewWidth;
        int surfaceViewHeight;
        if ((float) surfaceViewHeightDefault / (float) height > (float) surfaceViewWidthDefault / (float) width) {
            surfaceViewHeight = surfaceViewHeightDefault;
            surfaceViewWidth = surfaceViewHeight * width / height;
        } else {
            surfaceViewWidth = surfaceViewWidthDefault;
            surfaceViewHeight = surfaceViewWidth * height / width;
        }
        surfaceView.resize(surfaceViewWidth, surfaceViewHeight);
        Log.e(">>>>>>", "openDriver----surfaceView.getWidth():" + surfaceView.getWidth() + ",surfaceView.getHeight():" + surfaceView.getHeight());
        Log.e(">>>>>>", "openDriver----previewSizeOnScreen：" + previewSizeOnScreen.toString());
        Log.e(">>>>>>", "openDriver----修正--surfaceViewWidth：" + surfaceViewWidth + ",surfaceViewHeight:" + surfaceViewHeight);
    }

    public boolean isZoomSupported() {
        if (camera != null) {
            Camera camera = this.camera.getCamera();
            if (camera != null) {
                Camera.Parameters parameters = camera.getParameters();
                if (parameters != null) {
                    return parameters.isZoomSupported();
                }
            }
        }
        return false;
    }

    public void setZoom(int value) {
        try {
            if (camera != null) {
                Camera camera = this.camera.getCamera();
                if (camera != null) {
                    Camera.Parameters parameters = camera.getParameters();
                    if (parameters != null) {
                        if (parameters.isZoomSupported()) {
                            int maxZoom = parameters.getMaxZoom();
                            int currentValue = value * maxZoom / 100;
                            parameters.setZoom(currentValue);
                            //刷新
                            camera.setParameters(parameters);
                        }
                    }
                }
            }
        } catch (Exception e) {

        }
    }

    public synchronized boolean isOpen() {
        return camera != null;
    }

    /**
     * Closes the camera driver if still in use.
     */
    public synchronized void closeDriver() {
        if (camera != null) {
            camera.getCamera().release();
            camera = null;
            // Make sure to clear these each time we close the camera, so that any scanning rect
            // requested by intent is forgotten.
            framingRect = null;
            framingRectInPreview = null;
        }
    }

    /**
     * Asks the camera hardware to begin drawing preview frames to the screen.
     */
    public synchronized void startPreview() {
        OpenCamera theCamera = camera;
        if (theCamera != null && !previewing) {
            theCamera.getCamera().startPreview();
            previewing = true;
            autoFocusManager = new AutoFocusManager(context, theCamera.getCamera());
        }
    }

    /**
     * Tells the camera to stop drawing preview frames.
     */
    public synchronized void stopPreview() {
        if (autoFocusManager != null) {
            autoFocusManager.stop();
            autoFocusManager = null;
        }
        if (camera != null && previewing) {
            camera.getCamera().stopPreview();
            previewCallback.setHandler(null, 0);
            previewing = false;
        }
    }

    public void openLight() {
        if (camera != null && camera.getCamera() != null) {
            Camera.Parameters parameter = camera.getCamera().getParameters();
            parameter.setFlashMode(Camera.Parameters.FLASH_MODE_TORCH);
            camera.getCamera().setParameters(parameter);
        }
    }

    public void offLight() {
        if (camera != null && camera.getCamera() != null) {
            Camera.Parameters parameter = camera.getCamera().getParameters();
            parameter.setFlashMode(Camera.Parameters.FLASH_MODE_OFF);
            camera.getCamera().setParameters(parameter);
        }
    }

    /**
     * A single preview frame will be returned to the handler supplied. The data will arrive as byte[]
     * in the message.obj field, with width and height encoded as message.arg1 and message.arg2,
     * respectively.
     *
     * @param handler The handler to send the message to.
     * @param message The what field of the message to be sent.
     */
    public synchronized void requestPreviewFrame(Handler handler, int message) {
        OpenCamera theCamera = camera;
        if (theCamera != null && previewing) {
            previewCallback.setHandler(handler, message);
            theCamera.getCamera().setOneShotPreviewCallback(previewCallback);
        }
    }

    /**
     * Calculates the framing rect which the UI should draw to show the user where to place the
     * barcode. This target helps with alignment as well as forces the user to hold the device
     * far enough away to ensure the image will be in focus.
     *
     * @return The rectangle to draw on screen in window coordinates.
     */
    public synchronized Rect getFramingRect() {
        if (framingRect == null) {
            if (camera == null) {
                return null;
            }
            Point screenResolution = configManager.getScreenResolution();
            if (screenResolution == null) {
                // Called early, before init even finished
                return null;
            }

            MIN_FRAME_WIDTH = 3 * screenResolution.x / 10;
            MAX_FRAME_WIDTH = 9 * screenResolution.x / 10;
            int width = findDesiredDimensionInRange(screenResolution.x, MIN_FRAME_WIDTH, MAX_FRAME_WIDTH);
            int height = width;

            int leftOffset = (screenResolution.x - width) / 2;
            int topOffset = (screenResolution.y - height) / 2;
//            //高度偏移值
//            if (ScanSurfaceView.scanConfig != null) {
//                topOffset = topOffset - ScanSurfaceView.scanConfig.getScanFrameHeightOffsets();
//            }
            framingRect = new Rect(leftOffset, topOffset, leftOffset + width, topOffset + height);
            Log.d(TAG, "Calculated framing rect: " + framingRect);
        }
        return framingRect;
    }

    /**
     * 扫描框大小
     *
     * @param resolution
     * @param hardMin
     * @param hardMax
     * @return
     */
    private static int findDesiredDimensionInRange(int resolution, int hardMin, int hardMax) {
        int dim;
        //判断是不是全屏模式
        if (ScanSurfaceView.scanConfig != null && ScanSurfaceView.scanConfig.isFullScreenScan()) {
            dim = 9 * resolution / 10;
        } else {
            dim = 6 * resolution / 10;
        }
        if (dim < hardMin) {
            return hardMin;
        }
        if (dim > hardMax) {
            return hardMax;
        }
        return dim;
    }

    /**
     * Like {@link #getFramingRect} but coordinates are in terms of the preview frame,
     * not UI / screen.
     *
     * @return {@link Rect} expressing barcode scan area in terms of the preview size
     */
    public synchronized Rect getFramingRectInPreview() {
        if (framingRectInPreview == null) {
            Rect framingRect = getFramingRect();
            if (framingRect == null) {
                return null;
            }
            Rect rect = new Rect(framingRect);
            Point cameraResolution = configManager.getCameraResolution();
            Point screenResolution = configManager.getScreenResolution();
            if (cameraResolution == null || screenResolution == null) {
                // Called early, before init even finished
                return null;
            }
            //2017.11.13 添加竖屏代码处理
            if (screenResolution.x < screenResolution.y) {
                // portrait
                rect.left = rect.left * cameraResolution.y / screenResolution.x;
                rect.right = rect.right * cameraResolution.y / screenResolution.x;
                rect.top = rect.top * cameraResolution.x / screenResolution.y;
                rect.bottom = rect.bottom * cameraResolution.x / screenResolution.y;
            } else {
                // landscape
                rect.left = rect.left * cameraResolution.x / screenResolution.x;
                rect.right = rect.right * cameraResolution.x / screenResolution.x;
                rect.top = rect.top * cameraResolution.y / screenResolution.y;
                rect.bottom = rect.bottom * cameraResolution.y / screenResolution.y;
            }
            framingRectInPreview = rect;
        }
        return framingRectInPreview;
    }


    /**
     * Allows third party apps to specify the camera ID, rather than determine
     * it automatically based on available cameras and their orientation.
     *
     * @param cameraId camera ID of the camera to use. A negative value means "no preference".
     */
    public synchronized void setManualCameraId(int cameraId) {
        requestedCameraId = cameraId;
    }

    /**
     * Allows third party apps to specify the scanning rectangle dimensions, rather than determine
     * them automatically based on screen resolution.
     *
     * @param width  The width in pixels to scan.
     * @param height The height in pixels to scan.
     */
    public synchronized void setManualFramingRect(int width, int height) {
        if (initialized) {
            Point screenResolution = configManager.getScreenResolution();
            if (width > screenResolution.x) {
                width = screenResolution.x;
            }
            if (height > screenResolution.y) {
                height = screenResolution.y;
            }
            int leftOffset = (screenResolution.x - width) / 2;
            int topOffset = (screenResolution.y - height) / 2;
            framingRect = new Rect(leftOffset, topOffset, leftOffset + width, topOffset + height);
            Log.d(TAG, "Calculated manual framing rect: " + framingRect);
            framingRectInPreview = null;
        } else {
            requestedFramingRectWidth = width;
            requestedFramingRectHeight = height;
        }
    }

    /**
     * A factory method to build the appropriate LuminanceSource object based on the format
     * of the preview buffers, as described by Camera.Parameters.
     *
     * @param data   A preview frame.
     * @param width  The width of the image.
     * @param height The height of the image.
     * @return A PlanarYUVLuminanceSource instance.
     */
    public PlanarYUVLuminanceSource buildLuminanceSource(byte[] data, int width, int height) {
        Rect rect = getFramingRectInPreview();
        if (rect == null) {
            return null;
        }
        if (ScanSurfaceView.scanConfig != null && ScanSurfaceView.scanConfig.isFullScreenScan()) {
            //识别区域改为全屏
            return new PlanarYUVLuminanceSource(data, width, height, 0, 0,
                    width, height, false);
        }
        //识别区域是中间区域
        return new PlanarYUVLuminanceSource(data, width, height, rect.left, rect.top,
                rect.width(), rect.height(), false);

    }

    public Camera getCamera() {
        return camera.getCamera();
    }

    public CameraConfigurationManager getConfigManager(){
        return configManager;
    }
}
