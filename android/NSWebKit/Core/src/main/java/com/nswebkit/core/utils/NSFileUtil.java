package com.nswebkit.core.utils;

import com.nswebkit.core.base.NSApplicationProvider;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * @author Neil
 * @date 2023/5/24. description：
 */
public class NSFileUtil {

    public static String loadAssetAsStringTrimComment(String assetFilename) {
        String jsStr = "";
        try {
            InputStream in = NSApplicationProvider.getInstance().getApplication().getAssets().open(assetFilename);
            byte buff[] = new byte[1024];
            ByteArrayOutputStream fromFile = new ByteArrayOutputStream();
            do {
                int numRead = in.read(buff);
                if (numRead <= 0) {
                    break;
                }
                fromFile.write(buff, 0, numRead);
            } while (true);
            jsStr = fromFile.toString();
            in.close();
            fromFile.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return jsStr;
    }

    //android，添加js需要包裹在自执行函数里面
    public static String loadAssetJs(String assetFilename) {
        String addJs = loadAssetAsStringTrimComment(assetFilename);
        String js = new StringBuffer().append("var newscript = document.createElement(\"script\");")
                .append("newscript.innerHTML =" + "(function() {" + addJs + "})();")
                .append("document.head.appendChild(newscript);").toString();
        return js;
    }
}
