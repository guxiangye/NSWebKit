package com.nswebkit.core.utils;

import android.content.Context;
import android.graphics.Point;
import android.view.WindowManager;

import com.nswebkit.core.base.NSApplicationProvider;

/** author : blake e-mail : zhanglulu20140419@163.com date : 2019/3/1117:31 */
public class NSDisplayUtil {
  /** 将px值转换为dip或dp值，保证尺寸大小不变 */
  public static int px2dip(float pxValue) {
    final float scale = NSApplicationProvider.getInstance().getApplication().getResources().getDisplayMetrics().density;
    return (int) (pxValue / scale + 0.5f);
  }

  /** 将dip或dp值转换为px值，保证尺寸大小不变 */
  public static int dip2px(float dipValue) {
    final float scale = NSApplicationProvider.getInstance().getApplication().getResources().getDisplayMetrics().density;
    return (int) (dipValue * scale + 0.5f);
  }

  /** 将px值转换为sp值，保证文字大小不变 */
  public static int px2sp(float pxValue) {
    final float fontScale = NSApplicationProvider.getInstance()
            .getApplication()
            .getResources()
            .getDisplayMetrics()
            .scaledDensity;
    return (int) (pxValue / fontScale + 0.5f);
  }

  /** 将sp值转换为px值，保证文字大小不变 */
  public static int sp2px(float spValue) {
    final float fontScale = NSApplicationProvider.getInstance()
            .getApplication()
            .getResources()
            .getDisplayMetrics()
            .scaledDensity;
    return (int) (spValue * fontScale + 0.5f);
  }

  public static int getScreenWidth() {
    return NSApplicationProvider.getInstance()
        .getApplication()
        .getResources()
        .getDisplayMetrics()
        .widthPixels;
  }

  public static int getScreenHeight() {
    return NSApplicationProvider.getInstance()
        .getApplication()
        .getResources()
        .getDisplayMetrics()
        .heightPixels;
  }

  public static int getStatusBarHeight() {
    int result = 0;
    int resourceId = NSApplicationProvider.getInstance()
            .getApplication()
            .getResources()
            .getIdentifier("status_bar_height", "dimen", "android");
    if (resourceId > 0) {
      result = NSApplicationProvider.getInstance()
              .getApplication()
              .getResources()
              .getDimensionPixelSize(resourceId);
    }
    return result;
  }

  public static int getDisplayHeight(Context context) {
    WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
    Point size = new Point();
    assert wm != null;
    wm.getDefaultDisplay().getSize(size);
    return size.y;
  }

  public static int getWidthByRatio(int ratioWidth, int ratioHeight, int height) {
    int width = 0;
    if (ratioWidth != 0) {
      width = (int) (height * (ratioWidth * 1.0 / ratioHeight));
    }
    return width;
  }

  public static int getHeightByRatio(int ratioWidth, int ratioHeight, int width) {
    int height = 0;
    if (ratioWidth != 0) {
      height = (int) (width * (ratioHeight * 1.0 / ratioWidth));
    }
    return height;
  }
}
