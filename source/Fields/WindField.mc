import Toybox.Lang;
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Math;
import Toybox.Time;
import Toybox.Weather;
import Toybox.WatchUi;

class WindField extends BaseField {
    const WIND_SAMPLE_INTERVAL_MS = 10000;
    const BEARING_ALPHA = 0.30;
    const SPEED_ALPHA = 0.40;
    const HEADING_ALPHA = 0.50;
    const STALE_THRESHOLD_MS = 20 * 60 * 1000;

    hidden var myHaveWind = false;
    hidden var myHaveHeading = false;
    hidden var myStale = false;

    hidden var myWindBearingSin = 0.0;
    hidden var myWindBearingCos = 1.0;
    hidden var myWindSpeedSmooth = 0.0;
    hidden var myHeadingSin = 0.0;
    hidden var myHeadingCos = 1.0;

    hidden var myLastWindSampleMs = 0;

    function initialize() {
        BaseField.initialize();
    }

    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        var nowMs = Time.now().value();

        var haveHeading = info has :currentHeading && info.currentHeading != null;
        if (haveHeading) {
            var heading = info.currentHeading.toFloat();
            var hSin = Math.sin(heading);
            var hCos = Math.cos(heading);
            if (!myHaveHeading) {
                myHeadingSin = hSin;
                myHeadingCos = hCos;
                myHaveHeading = true;
            } else {
                myHeadingSin = HEADING_ALPHA * hSin + (1.0 - HEADING_ALPHA) * myHeadingSin;
                myHeadingCos = HEADING_ALPHA * hCos + (1.0 - HEADING_ALPHA) * myHeadingCos;
            }
        }

        if (nowMs - myLastWindSampleMs >= WIND_SAMPLE_INTERVAL_MS) {
            myLastWindSampleMs = nowMs;
            var sampleBearing = null;
            var sampleSpeed = null;
            var sampleObsMs = null;

            if (Weather has :getCurrentConditions) {
                try {
                    var conditions = Weather.getCurrentConditions();
                    if (conditions != null
                        && conditions has :windBearing && conditions.windBearing != null
                        && conditions has :windSpeed && conditions.windSpeed != null) {
                        sampleBearing = conditions.windBearing.toFloat();
                        sampleSpeed = conditions.windSpeed.toFloat();
                        if (conditions has :observationTime && conditions.observationTime != null) {
                            sampleObsMs = conditions.observationTime.value();
                        }
                    }
                } catch (ex) {
                }
            }

            if (sampleBearing != null) {
                var sSin = Math.sin(sampleBearing);
                var sCos = Math.cos(sampleBearing);
                if (!myHaveWind) {
                    myWindBearingSin = sSin;
                    myWindBearingCos = sCos;
                    myWindSpeedSmooth = sampleSpeed;
                    myHaveWind = true;
                } else {
                    myWindBearingSin = BEARING_ALPHA * sSin + (1.0 - BEARING_ALPHA) * myWindBearingSin;
                    myWindBearingCos = BEARING_ALPHA * sCos + (1.0 - BEARING_ALPHA) * myWindBearingCos;
                    myWindSpeedSmooth = SPEED_ALPHA * sampleSpeed + (1.0 - SPEED_ALPHA) * myWindSpeedSmooth;
                }

                if (sampleObsMs != null && (nowMs - sampleObsMs) > STALE_THRESHOLD_MS) {
                    myStale = true;
                } else {
                    myStale = false;
                }
            }
        }

        if (!myHaveWind || !myHaveHeading) {
            return new Field(layoutKey, "N/A", "");
        }

        var windBearing = Math.atan2(myWindBearingSin, myWindBearingCos);
        var heading = Math.atan2(myHeadingSin, myHeadingCos);

        var relative = windBearing - heading;
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

        var along = -myWindSpeedSmooth * Math.cos(relative);
        var alongKmh = along * 3.6;

        var speedLabel;
        if (alongKmh >= 0.0) {
            speedLabel = "+" + alongKmh.format("%d");
        } else {
            speedLabel = "-" + (-alongKmh).format("%d");
        }
        if (myStale) {
            speedLabel = "?" + speedLabel;
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
