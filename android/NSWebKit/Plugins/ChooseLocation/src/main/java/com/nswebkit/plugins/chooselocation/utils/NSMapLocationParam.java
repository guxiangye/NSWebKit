package com.nswebkit.plugins.chooselocation.utils;


import android.text.TextUtils;

import java.io.Serializable;

/**
 * @date 2022/11/3 on 13:57 @author: neil
 */
public class NSMapLocationParam implements Serializable {
    public static final int NSMapLocationSearchTypeNearby = 0;
    public static final int NSMapLocationSearchTypeKeyWord = 1;
    public static final int NSMapLocationSearchTypeKeyAuto = 2;

    public String types;
    public String city;
    public int  searchType;
    public boolean cityLimit;
    public int radius;

    public String getTypes(){
        if (TextUtils.isEmpty(types)){
            return "";
        }
        return types;
    }

}
