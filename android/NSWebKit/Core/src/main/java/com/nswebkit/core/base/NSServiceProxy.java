package com.nswebkit.core.base;

/**
 * 作者：Neil on 2021/7/27 11:21
 * <p>
 * www.github.com/guxiangyee/nswebkit.git
 * <p>
 * 作用： xxxx
 */
public class NSServiceProxy {

    private NSInitInterface initInterface;

    private static NSServiceProxy INSTANCE = new NSServiceProxy();

    public static NSServiceProxy getInstance() {
        return INSTANCE;
    }

    public void setInitInterface(NSInitInterface iface) {
        this.initInterface = iface;
    }

    public NSInitInterface getInitInterface() {
        return initInterface;
    }

}
