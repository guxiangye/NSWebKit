package com.nswebkit.plugins.basic.watermark;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.nswebkit.core.utils.NSDisplayUtil;
import com.nswebkit.plugins.basic.R;
import com.nswebkit.core.utils.NSColorUtil;

public class NSWatermarkView extends RelativeLayout {
    private TextView tvInfoText;
    private RelativeLayout root;

    public NSWatermarkView(Context context) {
        this(context, null);
    }

    public NSWatermarkView(Context context, AttributeSet attrs) {
        super(context, attrs);
        LayoutInflater.from(context).inflate(R.layout.layout_watermark_view, this, true);
        tvInfoText = findViewById(R.id.tv_info_text);
        root = findViewById(R.id.root);
    }

    public void setData(NSWatermarkBean data, Bitmap sourBitmap) {
        if (!TextUtils.isEmpty(data.getText())) {
            tvInfoText.setText(data.getText());
        }
        if (null != data.getFontSize()) {
            tvInfoText.setTextSize(NSDisplayUtil.px2dip(data.getFontSize()));
        }
        if (!TextUtils.isEmpty(data.getColor())) {
            tvInfoText.setTextColor(Color.parseColor(NSColorUtil.getColor(data.getColor())));
        }
        GradientDrawable gradientDrawable = new GradientDrawable();
        gradientDrawable.setShape(GradientDrawable.RECTANGLE);
        if (TextUtils.isEmpty(data.getBackgroundColor())) {
            gradientDrawable.setColor(Color.parseColor("#00000000"));
        } else {
            gradientDrawable.setColor(Color.parseColor(data.getBackgroundColor()));
        }
        if (null != data.getCornerRadius()) {
            gradientDrawable.setCornerRadius(NSDisplayUtil.px2dip(data.getCornerRadius()));
        }
        LayoutParams params = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
        if (null != data.getPadding()) {
            root.setPadding(NSDisplayUtil.px2dip(data.getPadding()), NSDisplayUtil.px2dip(data.getPadding()), NSDisplayUtil.px2dip(data.getPadding()), NSDisplayUtil.px2dip(data.getPadding()));
        }
        if (null != data.getMargin()) {
            params.setMargins(NSDisplayUtil.px2dip(data.getMargin()), NSDisplayUtil.px2dip(data.getMargin()), NSDisplayUtil.px2dip(data.getMargin()), NSDisplayUtil.px2dip(data.getMargin()));
        }
        tvInfoText.setMaxWidth(sourBitmap.getWidth());
        if (null != data.getPosition()) {
            switch (data.getPosition()) {
                case 0:
                case 2:
                    tvInfoText.setGravity(Gravity.START);
                    break;
                case 1:
                case 3:
                    tvInfoText.setGravity(Gravity.END);
                    break;
                case 4:
                    tvInfoText.setGravity(Gravity.CENTER);
                    break;
            }
        } else {
            tvInfoText.setGravity(Gravity.END);
        }
        root.setBackground(gradientDrawable);
        root.setLayoutParams(params);
    }
}
