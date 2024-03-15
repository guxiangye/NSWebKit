package com.nswebkit.plugins.basic.storage;

import android.text.TextUtils;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.nswebkit.core.base.NSApplicationProvider;
import com.nswebkit.core.utils.NSJsonUtil;
import com.nswebkit.plugins.basic.storage.base.NSSettings;

public class NSStorage {
    public NSStorage() {
    }

    public static void set(@NonNull String key, @NonNull Object value) {
        set(key, value, -1L, (String)null);
    }

    public static Object get(@NonNull String key) {
        return get(key, (String)null);
    }

    public static void set(@NonNull String key, @NonNull Object value, long second, @Nullable String ctag) {
        if (second <= 0L) {
            second = 315360000L;
        }

        StorageItem item = new StorageItem(value, System.currentTimeMillis() / 1000L + second);
        NSSettings settings = new NSSettings(NSApplicationProvider.getInstance().getApplication(), ctag);
        settings.set(key, NSJsonUtil.toJson(item));
    }

    public static Object get(@NonNull String key, @Nullable String ctag) {
        NSSettings settings = new NSSettings(NSApplicationProvider.getInstance().getApplication(), ctag);
        String data = settings.get(key, (String)null);
        Object retVal = null;
        if (!TextUtils.isEmpty(data)) {
            StorageItem item = (StorageItem) NSJsonUtil.fromJson(data, StorageItem.class);
            if (item != null) {
                if (item.expire * 1000L < System.currentTimeMillis()) {
                    settings.remove(key);
                } else {
                    retVal = item.value;
                }
            }
        }

        return retVal;
    }

    public static void remove(@NonNull String key, @Nullable String ctag) {
        NSSettings settings = new NSSettings(NSApplicationProvider.getInstance().getApplication(), ctag);
        settings.remove(key);
    }

    public static void clear(@Nullable String ctag) {
        NSSettings settings = new NSSettings(NSApplicationProvider.getInstance().getApplication(), ctag);
        settings.clear();
    }

    @Keep
    static class StorageItem {
        public Object value;
        public long expire;

        public StorageItem(Object value, long expire) {
            this.value = value;
            this.expire = expire;
        }
    }
}


