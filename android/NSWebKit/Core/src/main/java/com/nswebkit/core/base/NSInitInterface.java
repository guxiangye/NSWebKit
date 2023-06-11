package com.nswebkit.core.base;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

/**
 * 作者：Neil on 2021/7/27 11:14
 * <p>
 * www.github.com/guxiangyee/nswebkit.git
 * <p>
 * 作用： 宿主APP初始化信息
 */
public interface NSInitInterface {

    @NonNull
    String getDeviceId();
    String getImei();
    String getAppId();
    boolean isDev();
    @Nullable
    Map getExtendInfo();
}
