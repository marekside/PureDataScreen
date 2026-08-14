import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;

class WindArrowDrawable extends WatchUi.Drawable {
    hidden var myBlowAngle = 0.0;
    hidden var myFillColor = Graphics.COLOR_DK_GRAY;

    public function initialize() {
        Drawable.initialize({});
    }

    public function setBlowAngle(rad as Float) as Void {
        myBlowAngle = rad;
    }

    public function setFillColor(color as ColorType) as Void {
        myFillColor = color;
    }

    public function draw(dc as Dc) as Void {
        var w = width;
        var h = height;
        if (w == null || h == null || w <= 0 || h <= 0) {
            return;
        }

        var cx = locX + w * 0.28;
        var cy = locY + h * 0.50;

        var size = h * 0.40;
        var maxByWidth = w * 0.22;
        if (size > maxByWidth) {
            size = maxByWidth;
        }

        var sinT = Math.sin(myBlowAngle);
        var cosT = Math.cos(myBlowAngle);

        var tipX = cx + size * sinT;
        var tipY = cy - size * cosT;

        var baseCx = cx - size * 0.3 * sinT;
        var baseCy = cy + size * 0.3 * cosT;
        var baseHalf = size * 0.5;

        var b1x = baseCx + baseHalf * cosT;
        var b1y = baseCy + baseHalf * sinT;
        var b2x = baseCx - baseHalf * cosT;
        var b2y = baseCy - baseHalf * sinT;

        dc.setColor(myFillColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[tipX, tipY], [b1x, b1y], [b2x, b2y]]);
    }
}
