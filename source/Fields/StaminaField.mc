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

class StaminaField extends BaseField {
    hidden var myStamina = 100.0;
    hidden var myLastStamina = 100.0;
    hidden var myLastUpdateMs = 0;
    hidden var myEwmaRatio = 1.0;
    hidden var myHasHistory = false;

    // Drain: at ratio 1.0, 0%/s; at ratio 1.5, 1.5%/s (depletes 100% in ~67s).
    // Recover: at ratio 0.0, 4%/s (recovers 100% in 25s). Below ratio 0.7 there's no recovery.
    hidden const DRAIN_RATE = 3.0;
    hidden const RECOVER_RATE = 4.0;
    hidden const EWMA_ALPHA = 0.2;
    hidden const TREND_THRESHOLD = 0.5;
    // Cap dt so missed field-update ticks don't compound into a single huge drain/recovery.
    hidden const MAX_DT_SECONDS = 1.0;

    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        // Resolve the effort signal: power first, fall back to HR. Either returns null if unavailable.
        var signal = resolveSignal(info);
        if (signal == null) {
            return new Field(layoutKey, "-", "");
        }

        // Use System.getTimer() (monotonic, in milliseconds) for stable dt; clamp to avoid explosions.
        var nowMs = System.getTimer();
        var dt;
        if (myHasHistory) {
            dt = (nowMs - myLastUpdateMs).toFloat() / 1000.0;
        } else {
            dt = MAX_DT_SECONDS;
        }
        if (dt <= 0.0) { dt = MAX_DT_SECONDS; }
        if (dt > MAX_DT_SECONDS) { dt = MAX_DT_SECONDS; }

        // Update the EWMA-smoothed effort/threshold ratio so short spikes don't drain stamina instantly.
        myEwmaRatio = myEwmaRatio * (1.0 - EWMA_ALPHA) + signal[0].toFloat() / signal[1].toFloat() * EWMA_ALPHA;

        // Apply drain or recovery based on the smoothed ratio.
        if (myEwmaRatio > 1.0) {
            myStamina -= (myEwmaRatio - 1.0) * DRAIN_RATE * dt;
        } else {
            myStamina += (1.0 - myEwmaRatio) * RECOVER_RATE * dt;
        }
        if (myStamina < 0.0) { myStamina = 0.0; }
        if (myStamina > 100.0) { myStamina = 100.0; }

        // Determine the trend direction by comparing the latest sample to the previous one.
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
            field.setTextColor(Graphics.COLOR_BLACK);
            field.setLabelColor(Graphics.COLOR_LT_GRAY);
        } else {
            field.setBackgroundColor(Graphics.COLOR_RED);
            field.setTextColor(Graphics.COLOR_WHITE);
            field.setLabelColor(Graphics.COLOR_WHITE);
        }
        return field;
    }

    // Returns [effort, threshold] (both as Numbers) or null when neither power nor HR is available.
    // Power takes precedence; HR is the fallback when no power meter is paired.
    hidden function resolveSignal(info as Activity.Info) as Array? {
        if (info has :currentPower && info.currentPower != null && info.currentPower > 0) {
            var ftp = getFtp();
            if (ftp > 0) {
                return [info.currentPower, ftp];
            }
        }
        if (info has :currentHeartRate && info.currentHeartRate != null && info.currentHeartRate > 0) {
            var lthr = getLthr();
            if (lthr > 0) {
                return [info.currentHeartRate, lthr];
            }
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
        return 150;
    }

    // LTHR ≈ top of HR zone 4 (the maxZ4 threshold in the [minZ1, maxZ1..maxZ5] array).
    // Falls back to a sensible default if zones are unavailable.
    hidden function getLthr() as Number {
        try {
            if (UserProfile has :getHeartRateZones) {
                var sport = null;
                if (UserProfile has :getCurrentSport) {
                    sport = UserProfile.getCurrentSport();
                }
                var zones = UserProfile.getHeartRateZones(sport);
                if (zones != null && zones.size() >= 5 && zones[4] != null && zones[4] > 0) {
                    return zones[4];
                }
            }
        } catch (ex) {
        }
        return 170;
    }
}