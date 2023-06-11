package com.nswebkit.core.base;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Application;
import android.content.Context;

import androidx.annotation.NonNull;

public class NSApplicationProvider {

  @SuppressLint("StaticFieldLeak")
  private static volatile NSApplicationProvider instance;

  private Application mContext;

  public void attachContext(Context context) {
    if (context != null) {
      mContext =
          context instanceof Activity
              ? ((Activity) context).getApplication()
              : (Application) context.getApplicationContext();
    }
  }

  public static NSApplicationProvider getInstance() {
    if (instance == null) {
      synchronized (NSApplicationProvider.class) {
        if (instance == null) {
          instance = new NSApplicationProvider();
        }
      }
    }
    return instance;
  }

  @NonNull
  public Application getApplication() {
    return mContext;
  }
}
