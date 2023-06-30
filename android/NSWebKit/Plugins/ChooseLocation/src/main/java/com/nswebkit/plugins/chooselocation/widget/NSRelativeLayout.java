package com.nswebkit.plugins.chooselocation.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.WindowManager;
import android.widget.RelativeLayout;

/**
 * @date 2023/6/2 on 10:47 @author: neil
 */
public class NSRelativeLayout extends RelativeLayout {

  private Context mContext;

  public NSRelativeLayout(Context context) {

    super(context);

    mContext = context;

  }

  public NSRelativeLayout(Context context, AttributeSet attrs) {

    super(context, attrs);

    mContext = context;

  }

  public NSRelativeLayout(Context context, AttributeSet attrs, int defStyleAttr) {

    super(context, attrs, defStyleAttr);

    mContext = context;

  }

  public NSRelativeLayout(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {

    super(context, attrs, defStyleAttr, defStyleRes);

    mContext = context;

  }

  @Override

  protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {

    DisplayMetrics dm = new DisplayMetrics();

    WindowManager mWm = (WindowManager) mContext.getSystemService(Context.WINDOW_SERVICE);

    mWm.getDefaultDisplay().getMetrics(dm);

    int screenHeight = dm.heightPixels;

    heightMeasureSpec = MeasureSpec.makeMeasureSpec(screenHeight, MeasureSpec.EXACTLY);

    super.onMeasure(widthMeasureSpec, heightMeasureSpec);

  }

}

