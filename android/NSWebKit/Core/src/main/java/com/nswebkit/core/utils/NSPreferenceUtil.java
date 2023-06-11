package com.nswebkit.core.utils;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

/**
 * 作者：Neil on 2023/5/22 17:07
 * <p>
 * www.github.com/guxiangyee/nswebkit.git
 * <p>
 * 作用： xxxx
 */
public class NSPreferenceUtil {
    public static boolean isKeyExists(Context ctx, String key) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(ctx);
        return sp.contains(key);
    }

    public static void removeValue(Context ctx, String key) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(ctx);
        sp.edit().remove(key).commit();
    }

    public static String getStringValue(Context ctx, String key, String def) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(ctx);
        return sp.getString(key, def);
    }

    public static long getLongValue(Context ctx, String key, long def) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(ctx);
        return sp.getLong(key, def);
    }

    public static int getIntValue(Context ctx, String key, int def) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(ctx);
        return sp.getInt(key, def);
    }

    public static boolean getBooleanValue(Context ctx, String key, boolean def) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(ctx);
        return sp.getBoolean(key, def);
    }

    public static void setBooleanValue(Context ctx, String key, boolean value) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(ctx);
        SharedPreferences.Editor editor = sp.edit();
        editor.putBoolean(key, value);
        editor.commit();
    }

    public static void setIntValue(Context ctx, String key, int value) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(ctx);
        SharedPreferences.Editor editor = sp.edit();
        editor.putInt(key, value);
        editor.commit();
    }

    public static void setLongValue(Context ctx, String key, long value) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(ctx);
        SharedPreferences.Editor editor = sp.edit();
        editor.putLong(key, value);
        editor.commit();
    }

    public static void setStringValue(Context ctx, String key, String value) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(ctx);
        SharedPreferences.Editor editor = sp.edit();
        editor.putString(key, value);
        editor.commit();
    }

    public static boolean isKeyExists(Context ctx, String preferenceName, String key) {
        SharedPreferences sp = ctx.getSharedPreferences(preferenceName, Context.MODE_PRIVATE);
        if (sp == null) {
            return false;
        }
        return sp.contains(key);
    }

    public static void setStringValue(Context ctx, String preferenceName, String key, String value) {
        SharedPreferences sp = ctx.getSharedPreferences(preferenceName, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sp.edit();
        editor.putString(key, value);
        editor.commit();
    }

    public static String getStringValue(Context ctx, String preferenceName, String key, String def) {
        SharedPreferences sp = ctx.getSharedPreferences(preferenceName, Context.MODE_PRIVATE);
        return sp.getString(key, def);
    }

    public static void setIntValue(Context ctx, String preferenceName, String key, int value) {
        SharedPreferences sp = ctx.getSharedPreferences(preferenceName, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sp.edit();
        editor.putInt(key, value);
        editor.commit();
    }

    public static int getIntValue(Context ctx, String preferenceName, String key, int def) {
        SharedPreferences sp = ctx.getSharedPreferences(preferenceName, Context.MODE_PRIVATE);
        return sp.getInt(key, def);
    }

    public static void setBooleanValue(Context ctx, String preferenceName, String key, boolean value) {
        SharedPreferences sp = ctx.getSharedPreferences(preferenceName, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sp.edit();
        editor.putBoolean(key, value);
        editor.commit();
    }

    public static boolean getBooleanValue(Context ctx, String preferenceName, String key, boolean def) {
        SharedPreferences sp = ctx.getSharedPreferences(preferenceName, Context.MODE_PRIVATE);
        return sp.getBoolean(key, def);
    }

    public static void setLongValue(Context ctx, String preferenceName, String key, long value) {
        SharedPreferences sp = ctx.getSharedPreferences(preferenceName, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sp.edit();
        editor.putLong(key, value);
        editor.commit();
    }

    public static long getLongValue(Context ctx, String preferenceName, String key, long def) {
        SharedPreferences sp = ctx.getSharedPreferences(preferenceName, Context.MODE_PRIVATE);
        return sp.getLong(key, def);
    }
}
