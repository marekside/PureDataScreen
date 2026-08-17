import Toybox.Lang;
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Math;
import Toybox.System;
import Toybox.Weather;
import Toybox.WatchUi;

class WindField extends BaseField {
    hidden var myHaveWind = false;
    hidden var myWindBearing = 0.0;
    hidden var myWindSpeed = 0.0;

    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if (Weather has :getCurrentConditions) {
            try {
                var conditions = Weather.getCurrentConditions();
                if (conditions != null
                    && conditions has :windBearing && conditions.windBearing != null
                    && conditions has :windSpeed && conditions.windSpeed != null) {
                    myWindBearing = conditions.windBearing.toFloat();
                    myWindSpeed = conditions.windSpeed.toFloat();
                    myHaveWind = true;
                }
            } catch (ex) {
            }
        }

        if (!myHaveWind) {
            return new Field(layoutKey, "N/A", "");
        }

        var haveHeading = info has :currentHeading && info.currentHeading != null;
        if (!haveHeading) {
            return new Field(layoutKey, "N/A", "");
        }

        var heading = info.currentHeading.toFloat();
        var relative = myWindBearing - heading;
        var twoPi = 2.0 * Math.PI;
        while (relative > Math.PI) {
            relative = relative - twoPi;
        }
        while (relative < -Math.PI) {
            relative = relative + twoPi;
        }

        var blowAngle = relative + Math.PI;
        while (blowAngle > twoPi) {
            blowAngle = blowAngle - twoPi;
        }
        while (blowAngle < 0.0) {
            blowAngle = blowAngle + twoPi;
        }

        var along = -myWindSpeed * Math.cos(relative);
        var alongKmh = along * 3.6;

        var speedLabel;
        if (alongKmh >= 0.0) {
            speedLabel = "+" + alongKmh.format("%d");
        } else {
            speedLabel = "-" + (-alongKmh).format("%d");
        }

        var arrow = new WindArrowDrawable();
        arrow.setBlowAngle(blowAngle);

        var field = new Field(layoutKey, speedLabel, "");
        field.setCustomDrawable(arrow);

        if (alongKmh > 1.0) {
            field.setBackgroundColor(Graphics.COLOR_GREEN);
            field.setTextColor(Graphics.COLOR_BLACK);
            field.setLabelColor(Graphics.COLOR_LT_GRAY);
            arrow.setFillColor(Graphics.COLOR_BLACK);
        } else if (alongKmh < -1.0) {
            field.setBackgroundColor(Graphics.COLOR_RED);
            field.setTextColor(Graphics.COLOR_WHITE);
            field.setLabelColor(Graphics.COLOR_WHITE);
            arrow.setFillColor(Graphics.COLOR_WHITE);
        } else {
            arrow.setFillColor(Graphics.COLOR_DK_GRAY);
        }

        return field;
    }
}
