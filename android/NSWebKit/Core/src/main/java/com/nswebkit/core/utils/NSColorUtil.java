package com.nswebkit.core.utils;

public class NSColorUtil {

    public static String getColor(String color) {
        return color.contains("#") ? color : "#" + color;
    }
}
