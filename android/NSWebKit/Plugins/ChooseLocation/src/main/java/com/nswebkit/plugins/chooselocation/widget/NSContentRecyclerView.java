package com.nswebkit.plugins.chooselocation.widget;

import android.content.Context;
import android.os.Looper;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.ViewTreeObserver;
import android.widget.AbsListView;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;
import com.nswebkit.plugins.chooselocation.utils.NSViewUtil;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * @date 2023/6/1 on 14:17 @author: neil
 */
public class NSContentRecyclerView extends RecyclerView {

  private Context mContext;

  private final NSContentRecyclerView.CompositeScrollListener compositeScrollListener =
      new NSContentRecyclerView.CompositeScrollListener();

  public NSContentRecyclerView(Context context) {
    super(context);
    mContext = context;
  }

  public NSContentRecyclerView(Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
    mContext = context;
  }

  public NSContentRecyclerView(Context context, @Nullable AttributeSet attrs, int defStyle) {
    super(context, attrs, defStyle);
    mContext = context;
  }

  {
    super.addOnScrollListener(compositeScrollListener);
    getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
      @Override
      public void onGlobalLayout() {
        ViewGroup.LayoutParams layoutParams = getLayoutParams();
        ViewParent parent = getParent();
        while (parent != null) {
          if (parent instanceof NSDrawerLayout) {
            int height =
                ((NSDrawerLayout) parent).getMeasuredHeight() - ((NSDrawerLayout) parent).minOffset
                    - NSViewUtil.dip2px(mContext, 120);
            if (layoutParams.height == height) {
              return;
            } else {
              layoutParams.height = height;
              break;
            }
          }
          parent = parent.getParent();
        }
        setLayoutParams(layoutParams);
      }
    });
  }


  @Override
  protected void onAttachedToWindow() {
    super.onAttachedToWindow();
    ViewParent parent = getParent();
    while (parent != null) {
      if (parent instanceof NSDrawerLayout) {
        ((NSDrawerLayout) parent).setAssociatedRecyclerView(this);
        break;
      }
      parent = parent.getParent();
    }
  }

  @Override
  protected void onDetachedFromWindow() {
    super.onDetachedFromWindow();
  }

  private void throwIfNotOnMainThread() {
    if (Looper.myLooper() != Looper.getMainLooper()) {
      throw new IllegalStateException("Must be invoked from the main thread.");
    }
  }

  private class CompositeScrollListener extends OnScrollListener {

    private final List<RecyclerView.OnScrollListener> scrollListenerList = new
        ArrayList<RecyclerView.OnScrollListener>();

    public void addOnScrollListener(RecyclerView.OnScrollListener listener) {
      if (listener == null) {
        return;
      }
      for (RecyclerView.OnScrollListener scrollListener : scrollListenerList) {
        if (listener == scrollListener) {
          return;
        }
      }
      scrollListenerList.add(listener);
    }

    public void removeOnScrollListener(AbsListView.OnScrollListener listener) {
      if (listener == null) {
        return;
      }
      Iterator<RecyclerView.OnScrollListener> iterator = scrollListenerList.iterator();
      while (iterator.hasNext()) {
        RecyclerView.OnScrollListener scrollListener = iterator.next();
        if (listener == scrollListener) {
          iterator.remove();
          return;
        }
      }
    }

    @Override
    public void onScrollStateChanged(RecyclerView view, int scrollState) {
      List<RecyclerView.OnScrollListener> listeners = new ArrayList<RecyclerView.OnScrollListener>(
          scrollListenerList);
      for (RecyclerView.OnScrollListener listener : listeners) {
        listener.onScrollStateChanged(view, scrollState);
      }
    }

    @Override
    public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
      super.onScrolled(recyclerView, dx, dy);
      List<RecyclerView.OnScrollListener> listeners = new ArrayList<RecyclerView.OnScrollListener>(
          scrollListenerList);
      for (RecyclerView.OnScrollListener listener : listeners) {
        listener.onScrolled(recyclerView, dx, dy);
      }
    }
  }
}
