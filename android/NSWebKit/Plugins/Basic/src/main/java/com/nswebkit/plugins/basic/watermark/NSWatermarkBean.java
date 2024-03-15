package com.nswebkit.plugins.basic.watermark;

public class NSWatermarkBean {

    private String base64Image;
    private String imagePath;
    private String text;
    private String color;
    private String backgroundColor;
    private Integer cornerRadius;
    private Integer fontSize;
    private Integer position;
    private Integer margin;
    private Integer padding;

    public String getBase64Image() {
        return base64Image;
    }

    public void setBase64Image(String base64Image) {
        this.base64Image = base64Image;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getBackgroundColor() {
        return backgroundColor;
    }

    public void setBackgroundColor(String backgroundColor) {
        this.backgroundColor = backgroundColor;
    }

    public Integer getCornerRadius() {
        return cornerRadius;
    }

    public void setCornerRadius(Integer cornerRadius) {
        this.cornerRadius = cornerRadius;
    }

    public Integer getFontSize() {
        return fontSize;
    }

    public void setFontSize(Integer fontSize) {
        this.fontSize = fontSize;
    }

    public Integer getPosition() {
        return position;
    }

    public void setPosition(Integer position) {
        this.position = position;
    }

    public Integer getMargin() {
        return margin;
    }

    public void setMargin(Integer margin) {
        this.margin = margin;
    }

    public Integer getPadding() {
        return padding;
    }

    public void setPadding(Integer padding) {
        this.padding = padding;
    }

    @Override
    public String toString() {
        return "NSWatermarkBean{" +
                "base64Image='" + base64Image + '\'' +
                ", imagePath='" + imagePath + '\'' +
                ", text='" + text + '\'' +
                ", color='" + color + '\'' +
                ", backgroundColor='" + backgroundColor + '\'' +
                ", cornerRadius=" + cornerRadius +
                ", fontSize=" + fontSize +
                ", position=" + position +
                ", margin=" + margin +
                ", padding=" + padding +
                '}';
    }
}
