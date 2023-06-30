package com.nswebkit.plugins.chooselocation.widget;

import android.content.Context;
import android.content.res.TypedArray;
import android.os.Build;
import android.util.AttributeSet;
import android.util.Log;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.Scroller;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.StaggeredGridLayoutManager;
import com.nswebkit.plugins.chooselocation.R;
import com.nswebkit.plugins.chooselocation.utils.NSViewUtil;

/**
 * @date 2023/6/1 on 10:48 @author: neil
 */
public class NSDrawerLayout extends FrameLayout {

  private static final int MAX_SCROLL_DURATION = 400;
  private static final int MIN_SCROLL_DURATION = 100;
  private static final int FLING_VELOCITY_SLOP = 80;
  private static final int MOTION_DISTANCE_SLOP = 10;
  private static final float DRAG_SPEED_MULTIPLIER = 1.2f;
  private static final int DRAG_SPEED_SLOP = 30;
  private static final float SCROLL_TO_CLOSE_OFFSET_FACTOR = 0.5f;
  private static final float SCROLL_TO_EXIT_OFFSET_FACTOR = 0.8f;

  private float lastX;
  private float lastY;
  private float lastDownX;
  private float lastDownY;
  private int maxOffset = 0;
  public int minOffset = 0;
  private int exitOffset = 0;
  private final Scroller scroller;
  private final GestureDetector gestureDetector;
  private Status lastFlingStatus = Status.CLOSED;
  private InnerStatus currentInnerStatus = InnerStatus.OPENED;
  private boolean isSupportExit = false;
  private boolean isCurrentPointerIntercepted = false;
  private boolean isAllowPointerIntercepted = true;
  private boolean isDraggable = true;
  private OnScrollChangedListener onScrollChangedListener;

  private enum InnerStatus {
    EXIT, OPENED, CLOSED, MOVING, SCROLLING
  }

  /**
   * 表明NSDrawerLayout的状态,只可以打开或关闭。
   */
  public enum Status {
    EXIT, OPENED, CLOSED
  }

  private final GestureDetector.OnGestureListener gestureListener =
      new GestureDetector.SimpleOnGestureListener() {
        @Override
        public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
          Log.d("zhangbuniao", "onFling" + velocityY);
          if (velocityY > FLING_VELOCITY_SLOP) {
            if (lastFlingStatus.equals(Status.OPENED) && -getScrollY() > maxOffset) {
              lastFlingStatus = Status.EXIT;
              scrollToExit();
            } else {
              scrollToOpen();
              lastFlingStatus = Status.OPENED;
            }
            return true;
          } else if (velocityY < FLING_VELOCITY_SLOP && getScrollY() <= -maxOffset) {
            scrollToOpen();
            lastFlingStatus = Status.OPENED;
            return true;
          } else if (velocityY < FLING_VELOCITY_SLOP && getScrollY() > -maxOffset) {
            scrollToClose();
            lastFlingStatus = Status.CLOSED;
            return true;
          }
          return false;
        }
      };

  public NSDrawerLayout(Context context) {
    super(context);
  }

  public NSDrawerLayout(Context context, AttributeSet attrs) {
    super(context, attrs);
    initAttributes(context, attrs);
  }

  public NSDrawerLayout(Context context, AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    initAttributes(context, attrs);
  }

  {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
      scroller = new Scroller(getContext(), null, true);
    } else {
      scroller = new Scroller(getContext());
    }
    gestureDetector = new GestureDetector(getContext(), gestureListener);
  }

  private void initAttributes(Context context, AttributeSet attrs) {
    TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.NSDrawerLayout);
    if (typedArray.hasValue(R.styleable.NSDrawerLayout_maxOffset)) {
      int mMaxOffset = typedArray.getDimensionPixelOffset(R.styleable.NSDrawerLayout_maxOffset,
          maxOffset);
      if (mMaxOffset != NSViewUtil.getScreenHeight(context)) {
        maxOffset = NSViewUtil.getScreenHeight(context) - mMaxOffset;
      }
    }
    if (typedArray.hasValue(R.styleable.NSDrawerLayout_minOffset)) {
      minOffset = typedArray.getDimensionPixelOffset(R.styleable.NSDrawerLayout_minOffset,
          minOffset);
    }
    if (typedArray.hasValue(R.styleable.NSDrawerLayout_exitOffset)) {
      int mExitOffset = typedArray.getDimensionPixelOffset(R.styleable.NSDrawerLayout_exitOffset,
          NSViewUtil.getScreenHeight(context));
      if (mExitOffset != NSViewUtil.getScreenHeight(context)) {
        exitOffset = NSViewUtil.getScreenHeight(context) - mExitOffset;
      }
    }
    if (typedArray.hasValue(R.styleable.NSDrawerLayout_mode)) {
      int mode = typedArray.getInteger(R.styleable.NSDrawerLayout_mode, 0);
      switch (mode) {
        case 0x0:
          setToOpen();
          break;
        case 0x1:
          setToClosed();
          break;
        case 0x2:
          setToExit();
          break;
        default:
          setToClosed();
          break;
      }
    }
    typedArray.recycle();
  }


  @Override
  public void scrollTo(int x, int y) {
    super.scrollTo(x, y);
    Log.d("zhangbuniao", "scrollTo,y=" + y);
    if (maxOffset == minOffset) {
      return;
    }
    //只有从最小值到最大值或者最大值到最小值的时候回调进度，不退出
    if (-y <= maxOffset) {
      float progress = (float) (-y - minOffset) / (maxOffset - minOffset);
      onScrollProgressChanged(progress);
    } else {
      float progress = (float) (-y - maxOffset) / (maxOffset - exitOffset);
      onScrollProgressChanged(progress);
    }
    if (y == -minOffset) {
      // 关闭
      if (currentInnerStatus != InnerStatus.CLOSED) {
        currentInnerStatus = InnerStatus.CLOSED;
        onScrollFinished(Status.CLOSED);
      }
    } else if (y == -maxOffset) {
      // 打开
      if (currentInnerStatus != InnerStatus.OPENED) {
        currentInnerStatus = InnerStatus.OPENED;
        onScrollFinished(Status.OPENED);
      }
    } else if (isSupportExit && y == -exitOffset) {
      // 完全退出
      if (currentInnerStatus != InnerStatus.EXIT) {
        currentInnerStatus = InnerStatus.EXIT;
        onScrollFinished(Status.EXIT);
      }
    }
  }

  private void onScrollFinished(Status status) {
    if (onScrollChangedListener != null) {
      onScrollChangedListener.onScrollFinished(status);
    }
  }

  private void onScrollProgressChanged(float progress) {
    if (onScrollChangedListener != null) {
      onScrollChangedListener.onScrollProgressChanged(progress);
    }
  }

  @Override
  public void computeScroll() {
    Log.d("zhangbuniao", "computeScroll" + scroller.getCurrY());
    if (!scroller.isFinished() && scroller.computeScrollOffset()) {
      int currY = scroller.getCurrY();
      scrollTo(0, currY);
      if (currY == -minOffset || currY == -maxOffset || (isSupportExit && currY == -exitOffset)) {
        scroller.abortAnimation();
      } else {
        invalidate();
      }
    }
  }

  @Override
  public boolean onInterceptTouchEvent(MotionEvent ev) {
    Log.d("zhangbuniao", "onInterceptTouchEvent" + ev.getY());
    if (!isDraggable && currentInnerStatus == InnerStatus.CLOSED) {
      return false;
    }
    switch (ev.getAction()) {
      case MotionEvent.ACTION_DOWN:
        lastX = ev.getX();
        lastY = ev.getY();
        lastDownX = lastX;
        lastDownY = lastY;
        isAllowPointerIntercepted = true;
        isCurrentPointerIntercepted = false;
        if (!scroller.isFinished()) {
          scroller.forceFinished(true);
          currentInnerStatus = InnerStatus.MOVING;
          isCurrentPointerIntercepted = true;
          return true;
        }
        break;
      case MotionEvent.ACTION_UP:
      case MotionEvent.ACTION_CANCEL:
        isAllowPointerIntercepted = true;
        isCurrentPointerIntercepted = false;
        if (currentInnerStatus == InnerStatus.MOVING) {
          return true;
        }
        break;
      case MotionEvent.ACTION_MOVE:
        if (!isAllowPointerIntercepted) {
          return false;
        }
        if (isCurrentPointerIntercepted) {
          return true;
        }
        int deltaY = (int) (ev.getY() - lastDownY);
        int deltaX = (int) (ev.getX() - lastDownX);
        if (Math.abs(deltaY) < MOTION_DISTANCE_SLOP) {
          return false;
        }
        if (currentInnerStatus == InnerStatus.CLOSED) {
          // 关闭时，仅处理向下滑动事件
          if (deltaY < 0) {// 向上
            return false;
          }
        } else if (currentInnerStatus == InnerStatus.OPENED && !isSupportExit) {
          // 打开时，仅处理向上滑动事件
          if (deltaY > 0) { // 向下
            return false;
          }
        }
        isCurrentPointerIntercepted = true;
        return true;
      default:
        return false;
    }
    return false;
  }

  @Override
  public boolean onTouchEvent(MotionEvent event) {
    Log.d("zhangbuniao", "onTouchEvent" + event.getY());
    if (!isCurrentPointerIntercepted) {
      return false;
    }
    gestureDetector.onTouchEvent(event);
    switch (event.getAction()) {
      case MotionEvent.ACTION_DOWN:
        lastY = event.getY();
        return true;
      case MotionEvent.ACTION_MOVE:
        int deltaY = (int) ((event.getY() - lastY) * DRAG_SPEED_MULTIPLIER);
        deltaY = (int) (Math.signum(deltaY)) * Math.min(Math.abs(deltaY), DRAG_SPEED_SLOP);
        if (disposeEdgeValue(deltaY)) {
          return true;
        }
        currentInnerStatus = InnerStatus.MOVING;
        int toScrollY = getScrollY() - deltaY;
        if (toScrollY >= -minOffset) {
          scrollTo(0, -minOffset);
        } else if (toScrollY <= -maxOffset && !isSupportExit) {
          scrollTo(0, -maxOffset);
        } else {
          scrollTo(0, toScrollY);
        }
        lastY = event.getY();
        return true;
      case MotionEvent.ACTION_UP:
      case MotionEvent.ACTION_CANCEL:
        if (currentInnerStatus == InnerStatus.MOVING) {
          completeMove();
          return true;
        }
        break;
      default:
        return false;
    }
    return false;
  }

  private boolean disposeEdgeValue(int deltaY) {
    if (isSupportExit) {
      if (deltaY <= 0 && getScrollY() >= -minOffset) {
        return true;
      } else if (deltaY >= 0 && getScrollY() <= -exitOffset) {
        return true;
      }
    } else {
      if (deltaY <= 0 && getScrollY() >= -minOffset) {
        return true;
      } else if (deltaY >= 0 && getScrollY() <= -maxOffset) {
        return true;
      }
    }
    return false;
  }

  private void completeMove() {
    float closeValue = -((maxOffset - minOffset) * SCROLL_TO_CLOSE_OFFSET_FACTOR);
    if (getScrollY() > closeValue) {
      scrollToClose();
    } else {
      if (isSupportExit) {
        float exitValue = -((exitOffset - maxOffset) * SCROLL_TO_EXIT_OFFSET_FACTOR + maxOffset);
        if (getScrollY() <= closeValue && getScrollY() > exitValue) {
          scrollToOpen();
        } else {
          scrollToExit();
        }
      } else {
        scrollToOpen();
      }
    }
  }


  /**
   * 滚动布局开放,maxOffset之后向下滚动.
   */
  public void scrollToOpen() {
    if (currentInnerStatus == InnerStatus.OPENED) {
      return;
    }
    if (maxOffset == minOffset) {
      return;
    }
    int dy = -getScrollY() - maxOffset;
    if (dy == 0) {
      return;
    }
    currentInnerStatus = InnerStatus.SCROLLING;
    int duration = MIN_SCROLL_DURATION
        + Math.abs((MAX_SCROLL_DURATION - MIN_SCROLL_DURATION) * dy / (maxOffset - minOffset));
    scroller.startScroll(0, getScrollY(), 0, dy, duration);
    invalidate();
  }

  /**
   * 滚动的布局来关闭,滚动到minOffset.
   */
  public void scrollToClose() {
    if (currentInnerStatus == InnerStatus.CLOSED) {
      return;
    }
    if (maxOffset == minOffset) {
      return;
    }
    int dy = -getScrollY() - minOffset;
    if (dy == 0) {
      return;
    }
    currentInnerStatus = InnerStatus.SCROLLING;
    int duration = MIN_SCROLL_DURATION
        + Math.abs((MAX_SCROLL_DURATION - MIN_SCROLL_DURATION) * dy / (maxOffset - minOffset));
    scroller.startScroll(0, getScrollY(), 0, dy, duration);
    invalidate();
  }

  /**
   * 滚动布局退出
   */
  public void scrollToExit() {
    if (!isSupportExit) {
      return;
    }
    if (currentInnerStatus == InnerStatus.EXIT) {
      return;
    }
    if (exitOffset == maxOffset) {
      return;
    }
    int dy = -getScrollY() - exitOffset;
    if (dy == 0) {
      return;
    }
    currentInnerStatus = InnerStatus.SCROLLING;
    int duration = MIN_SCROLL_DURATION
        + Math.abs((MAX_SCROLL_DURATION - MIN_SCROLL_DURATION) * dy / (exitOffset - maxOffset));
    scroller.startScroll(0, getScrollY(), 0, dy, duration);
    invalidate();
  }

  /**
   * 初始化布局开放
   */
  public void setToOpen() {
    scrollTo(0, -maxOffset);
    currentInnerStatus = InnerStatus.OPENED;
    lastFlingStatus = Status.OPENED;
  }

  /**
   * 初始化布局关
   */
  public void setToClosed() {
    scrollTo(0, -minOffset);
    currentInnerStatus = InnerStatus.CLOSED;
    lastFlingStatus = Status.CLOSED;
  }

  /**
   * 初始化布局,退出。
   */
  public void setToExit() {
    if (!isSupportExit) {
      return;
    }
    scrollTo(0, -exitOffset);
    currentInnerStatus = InnerStatus.EXIT;
  }

  public void setMinOffset(int minOffset) {
    this.minOffset = minOffset;
  }

  public void setMaxOffset(int maxOffset) {
    this.maxOffset = NSViewUtil.getScreenHeight(getContext()) - maxOffset;
  }

  public void setExitOffset(int exitOffset) {
    this.exitOffset = NSViewUtil.getScreenHeight(getContext()) - exitOffset;
  }

  public void setDraggable(boolean draggable) {
    this.isDraggable = draggable;
  }

  public void setIsSupportExit(boolean isSupportExit) {
    this.isSupportExit = isSupportExit;
  }

  public boolean isSupportExit() {
    return isSupportExit;
  }

  /**
   * RecyclerView嵌套，相关互动冲突解决
   *
   * @param recyclerView
   */
  public void setAssociatedRecyclerView(RecyclerView recyclerView) {
    recyclerView.addOnScrollListener(associatedRecyclerViewListener);
    updateRecyclerViewScrollState(recyclerView);
  }

  private void updateRecyclerViewScrollState(RecyclerView recyclerView) {
    if (recyclerView.getChildCount() == 0) {
      setDraggable(true);
    } else {
      RecyclerView.LayoutManager layoutManager = recyclerView.getLayoutManager();
      int[] i = new int[1];
      if (layoutManager instanceof LinearLayoutManager
          || layoutManager instanceof GridLayoutManager) {
        i[0] = ((LinearLayoutManager) layoutManager).findFirstVisibleItemPosition();
      } else if (layoutManager instanceof StaggeredGridLayoutManager) {
        i = null;
        i = ((StaggeredGridLayoutManager) layoutManager).findFirstVisibleItemPositions(i);
      }
      if (i[0] == 0) {
        View firstChild = recyclerView.getChildAt(0);
        if (firstChild.getTop() == recyclerView.getPaddingTop()) {
          setDraggable(true);
          return;
        }
      }
      setDraggable(false);
    }
  }

  private final RecyclerView.OnScrollListener associatedRecyclerViewListener =
      new RecyclerView.OnScrollListener() {
        @Override
        public void onScrollStateChanged(RecyclerView recyclerView, int newState) {
          super.onScrollStateChanged(recyclerView, newState);
          updateRecyclerViewScrollState(recyclerView);
        }

        @Override
        public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
          super.onScrolled(recyclerView, dx, dy);
          updateRecyclerViewScrollState(recyclerView);
        }
      };


  public void setOnScrollChangedListener(OnScrollChangedListener listener) {
    this.onScrollChangedListener = listener;
  }

  /**
   * 注册这个NSDrawerLayout可以监控其滚动
   */
  public interface OnScrollChangedListener {

    /**
     * 每次滚动改变值
     *
     * @param currentProgress 0对1，1对-1，0表示关闭，1表示打开，-1表示退出。
     */
    void onScrollProgressChanged(float currentProgress);

    /**
     * 滚动状态改变时调用的方法
     *
     * @param currentStatus 更改后的当前状态
     */
    void onScrollFinished(Status currentStatus);

    /***
     * 滚动子视图
     *
     * @param top 子视图滚动回调
     */
    void onChildScroll(int top);
  }

}
