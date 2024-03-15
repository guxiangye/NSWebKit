package com.nswebkit.core.utils;

import com.google.gson.Gson;
import com.google.gson.JsonParseException;
import java.lang.reflect.Type;
import java.util.HashMap;
import org.json.JSONException;
import org.json.JSONObject;

/** author: tang created on: 2019-09-19 16:09 description: */
public class NSJsonUtil {

  private static final Gson gson = new Gson();

  //  public static Gson getGson() {
  //    return gson;
  //  }

  public static String toJson(Object obj) {
    return gson.toJson(obj);
  }

  public static String toJson(Object src, Type typeOfSrc) {
    return gson.toJson(src, typeOfSrc);
  }

  public static <T> T fromJson(String rawJson, Class<T> beanClass) throws JsonParseException {
    return gson.fromJson(rawJson, beanClass);
  }

  public static <T> T fromJson(String json, Type typeOfT) throws JsonParseException {
    return gson.fromJson(json, typeOfT);
  }

  public static JSONObject hashMap2JsonObject(HashMap<String, String> map) {
    if (map == null) {
      return null;
    }
    JSONObject o = new JSONObject();
    try {
      if (map != null) {
        for (String key : map.keySet()) {
          o.put(key, map.get(key));
        }
      }
    } catch (JSONException e) {
      e.printStackTrace();
    }

    return o;
  }

  private static void addIndentBlank(StringBuilder sb, int indent) {
    try {
      for (int i = 0; i < indent; i++) {
        sb.append('\t');
      }
    } catch (Exception e) {
    }
  }

  public static String formatJson(String jsonStr) {
    try {
      if (null == jsonStr || "".equals(jsonStr)) {
        return "";
      }
      StringBuilder sb = new StringBuilder();
      char last = '\0';
      char current = '\0';
      int indent = 0;
      boolean isInQuotationMarks = false;
      for (int i = 0; i < jsonStr.length(); i++) {
        last = current;
        current = jsonStr.charAt(i);
        switch (current) {
          case '"':
            if (last != '\\') {
              isInQuotationMarks = !isInQuotationMarks;
            }
            sb.append(current);
            break;
          case '{':
          case '[':
            sb.append(current);
            if (!isInQuotationMarks) {
              sb.append('\n');
              indent++;
              addIndentBlank(sb, indent);
            }
            break;
          case '}':
          case ']':
            if (!isInQuotationMarks) {
              sb.append('\n');
              indent--;
              addIndentBlank(sb, indent);
            }
            sb.append(current);
            break;
          case ',':
            sb.append(current);
            if (last != '\\' && !isInQuotationMarks) {
              sb.append('\n');
              addIndentBlank(sb, indent);
            }
            break;
          case '\\':
            break;
          default:
            sb.append(current);
        }
      }
      return sb.toString();
    } catch (Exception e) {
      return "";
    }
  }

  /*
  public static HashMap<String, String> jsonObject2HashMap(JSONObject json) {
    if (json == null) {
      return null;
    }
    HashMap<String, String> map = new HashMap<>();
    for (Iterator<String> keys = json.keys(); keys.hasNext(); ) {
      String key = keys.next();
      map.put(key, json.optString(key));
    }
    return map;
  }

  public static String jsonObject2StringParams(JSONObject json) {
    if (json == null) {
      return "";
    }
    String params = "";
    for (Iterator<String> keys = json.keys(); keys.hasNext(); ) {
      String key = keys.next();
      params += key + "=" + json.optString(key) + "&";
    }
    if (params.endsWith("&")) {
      params = params.substring(0, params.length() - 1);
    }

    return params;
  }

  public static Bundle jsonObject2Bundle(JSONObject json) {
    if (json == null) {
      return null;
    }
    Bundle bundle = new Bundle();
    for (Iterator<String> keys = json.keys(); keys.hasNext(); ) {
      String key = keys.next();
      bundle.putString(key, json.optString(key));
    }

    return bundle;
  }
   */
}
