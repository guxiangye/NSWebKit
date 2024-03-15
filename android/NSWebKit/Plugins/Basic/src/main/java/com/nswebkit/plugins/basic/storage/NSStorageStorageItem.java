package com.nswebkit.plugins.basic.storage;

import androidx.annotation.Keep;

@Keep
class NSStorageStorageItem {
	public Object value;
	public long expire;

	public NSStorageStorageItem(Object value, long expire) {
		this.value = value;
		this.expire = expire;
	}
}
