import Toybox.Lang;
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.UserProfile;
import Toybox.WatchUi;

// Field value that paints a trend arrow (↑/↓) to the left of the value label
// via the standard hasCustomDrawing / draw hooks on Field.
class StaminaFieldValue extends Field {
    hidden var myTrend = 0; // -1 draining, 0 flat, +1 recovering

    public function initialize(name as String, value as String, decimal as String) {
        Field.initialize(name, value, decimal);
    }

    public function setTrend(trend as Number) as Void {
        myTrend = trend;
    }

    public function hasCustomDrawing() as Boolean {
        return true;
    }

    public function draw(dc as Dc, cx as Numeric, cy as Numeric, size as Numeric, foregroundColor as ColorType) as Void {
        var arrow;
        if (myTrend > 0) {
            arrow = "+";
        } else if (myTrend < 0) {
            arrow = "-";
        } else {
            return;
        }
        dc.setColor(foregroundColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy, Graphics.FONT_MEDIUM, arrow, Graphics.TEXT_JUSTIFY_LEFT);
    }
}

// W'bal-lite stamina model.
//
// Threshold model:
//   - AeT = top of zone 1 (maxZ1). Below AeT: stamina recovers.
//   - AnT = top of zone 4 (maxZ4). Above AnT: stamina drains at full rate.
//   - Zone 1..Zone 4: linearly ramps from 0 to full drain intensity.
//     Zone 2 (aerobic base) sits comfortably in the low-drain half of this ramp.
//   - Zone 5: clamped at full drain.
//
// Effort signal:
//   - Power preferred; falls back to HR. Each signal carries its own threshold.
//   - For HR: AeT = zones[1] (maxZ1), AnT = zones[4] (maxZ4).
//   - For power: AeT ≈ 0.55 * FTP (zone 1 equivalent), AnT = FTP.
class StaminaField extends BaseField {
    hidden var myStamina = 100.0;
    hidden var myLastStamina = 100.0;
    hidden var myLastUpdateMs = 0;
    hidden var myHasHistory = false;
    hidden var myAet = 0.0;
    hidden var myAnt = 0.0;
    hidden var myHaveThresholds = false;

    // %/s at 1.0 normalised excess above the threshold. With DRAIN_RATE=3 and excess=1.0
    // (effort = 2x threshold) we drain 3%/s. At excess=0.2 we drain 0.6%/s.
    hidden const DRAIN_RATE = 3.0;
    // %/s recovery at 1.0 normalised deficit below the threshold (effort=0).
    hidden const RECOVER_RATE = 4.0;
    hidden const TREND_THRESHOLD = 0.5;
    hidden const MAX_DT_SECONDS = 1.0;

    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        var signal = resolveSignal(info);
        if (signal == null) {
            return new Field(layoutKey, "-", "");
        }
        var effort = signal[0].toFloat();
        var aet = myAet;
        var ant = myAnt;

        var nowMs = System.getTimer();
        var dt;
        if (myHasHistory) {
            dt = (nowMs - myLastUpdateMs).toFloat() / 1000.0;
        } else {
            dt = MAX_DT_SECONDS;
        }
        if (dt <= 0.0) { dt = MAX_DT_SECONDS; }
        if (dt > MAX_DT_SECONDS) { dt = MAX_DT_SECONDS; }

        // Map effort to a signed (-1..+1) intensity:
        //   effort == aet -> 0  (baseline, no change)
        //   effort >= ant -> 1  (full drain rate)
        //   effort <= aet -> negative, recovery proportional to how far below AeT
        //   (aet..ant)    -> linearly interpolated 0..1
        var intensity;
        if (effort >= ant && ant > aet) {
            intensity = 1.0;
        } else if (effort >= aet) {
            intensity = (effort - aet) / (ant - aet);
        } else if (aet > 0.0) {
            intensity = (effort - aet) / aet; // negative when below AeT
        } else {
            intensity = 0.0;
        }

        if (intensity > 0.0) {
            myStamina -= intensity * DRAIN_RATE * dt;
        } else if (intensity < 0.0) {
            myStamina += -intensity * RECOVER_RATE * dt;
        }
        if (myStamina < 0.0) { myStamina = 0.0; }
        if (myStamina > 100.0) { myStamina = 100.0; }

        //System.println("StaminaField: effort=" + effort + " aet=" + aet + " ant=" + ant + " intensity=" + intensity + " stamina=" + myStamina);

        var trend = 0;
        if (myStamina > myLastStamina + TREND_THRESHOLD) { trend = 1; }
        else if (myStamina < myLastStamina - TREND_THRESHOLD) { trend = -1; }

        myLastStamina = myStamina;
        myLastUpdateMs = nowMs;
        myHasHistory = true;

        var field = new StaminaFieldValue(layoutKey, myStamina.format("%d"), "");
        field.setTrend(trend);
        if (myStamina > 50.0) {
            field.setBackgroundColor(Graphics.COLOR_GREEN);
            field.setTextColor(Graphics.COLOR_BLACK);
            field.setLabelColor(Graphics.COLOR_LT_GRAY);
        } else if (myStamina > 20.0) {
            field.setBackgroundColor(Graphics.COLOR_YELLOW);
            field.setTextColor(Graphics.COLOR_WHITE);
            field.setLabelColor(Graphics.COLOR_WHITE);
        } else {
            field.setBackgroundColor(Graphics.COLOR_RED);
            field.setTextColor(Graphics.COLOR_WHITE);
            field.setLabelColor(Graphics.COLOR_WHITE);
        }
        return field;
    }

    // Returns [effort] (Number) or null when neither power nor HR is available.
    // Thresholds are resolved lazily and cached on the instance.
    hidden function resolveSignal(info as Activity.Info) as Array? {
        if (!myHaveThresholds) {
            if (info has :currentPower && info.currentPower != null && info.currentPower > 0) {
                var ftp = getFtp();
                if (ftp > 0) {
                    myAnt = ftp.toFloat();
                    myAet = ftp.toFloat() * 0.55;
                    myHaveThresholds = true;
                }
            }
            if (!myHaveThresholds && info has :currentHeartRate && info.currentHeartRate != null && info.currentHeartRate > 0) {
                var zones = getHrZones();
                if (zones != null && zones.size() >= 5 && zones[1] != null && zones[4] != null
                    && zones[1] > 0 && zones[4] > zones[1]) {
                    myAet = zones[1].toFloat();
                    myAnt = zones[4].toFloat();
                    myHaveThresholds = true;
                }
            }
            if (!myHaveThresholds) {
                return null;
            }
        }

        if (info has :currentPower && info.currentPower != null && info.currentPower > 0) {
            return [info.currentPower];
        }
        if (info has :currentHeartRate && info.currentHeartRate != null && info.currentHeartRate > 0) {
            return [info.currentHeartRate];
        }
        return null;
    }

    hidden function getFtp() as Number {
        try {
            if (UserProfile has :getFunctionalThresholdPower) {
                var ftp = UserProfile.getFunctionalThresholdPower(Activity.SPORT_CYCLING);
                if (ftp != null && ftp > 0) {
                    return ftp;
                }
            }
        } catch (ex) {
        }
        return 200;
    }

    // Returns the [minZ1, maxZ1, maxZ2, maxZ3, maxZ4, maxZ5] array, or null.
    hidden function getHrZones() as Array? {
        try {
            if (UserProfile has :getHeartRateZones) {
                var sport = null;
                if (UserProfile has :getCurrentSport) {
                    sport = UserProfile.getCurrentSport();
                }
                return UserProfile.getHeartRateZones(sport);
            }
        } catch (ex) {
        }
        return null;
    }
}
