import Toybox.Lang;
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.System;
import Toybox.UserProfile;
import Toybox.WatchUi;

// W'bal-lite stamina model with two tanks: W'bal (fast, anaerobic capacity)
// and Energy (slow, glycogen-like endurance).
//
// Threshold model:
//   - AeT = top of zone 2 (maxZ2). Below AeT: both tanks recover.
//   - AnT = top of zone 5 (maxZ5). Above AnT: both tanks drain at full rate.
//   - Zones 3, 4, 5: linearly ramp from 0 to full drain intensity.
//     Zones 1 and 2 (aerobic base) sit in the recovery band.
//
// Same intensity function drives both tanks at very different rates:
//
//   Tank       Drain rate  Recovery rate  Empty in (at FTP)  Empty in (at Z2)
//   W'bal      0.125 %/s   0.15 %/s       ~20 min            recovers
//   Energy     0.028 %/s   0.02 %/s       ~90 min            ~5 h
//
// Displayed stamina = min(W'bal, Energy) so the athlete always sees the
// current bottleneck.
//
// Effort signal:
//   - Power preferred; falls back to HR. Each signal carries its own threshold.
//   - For power: uses configured power zones when available
//     (AeT = maxZ2, AnT = maxZ5), else FTP-based fallback
//     AeT = 0.75 * FTP, AnT = 1.20 * FTP.
//   - For HR: AeT = zones[2] (maxZ2), AnT = zones[5] (maxZ5).
class StaminaField extends BaseField {
    hidden var myStamina = 100.0;
    hidden var myEnergy = 100.0;
    hidden var myLastStamina = 100.0;
    hidden var myLastUpdateMs = 0;
    hidden var myHasHistory = false;
    hidden var myAet = 0.0;
    hidden var myAnt = 0.0;
    // Raw zone array returned by the device's UserProfile: [minZ1, maxZ1, maxZ2, maxZ3, maxZ4, maxZ5].
    // Null when no configured zones are available (FTP fallback for power, or no HR zones).
    hidden var myZones = null;
    hidden var myHaveThresholds = false;

    // W'bal tank: %/s at intensity = 1.0. At FTP (intensity 2/3), depletes
    // 100% -> 0% in 20 minutes: 100 / (0.125 * 2/3) = 1200 s.
    hidden const DRAIN_RATE = 0.125;
    // W'bal recovery: %/s at intensity = -1.0 (effort = 0). 0% -> 100% in ~667 s.
    hidden const RECOVER_RATE = 0.15;
    // Energy (glycogen) tank: %/s at intensity = 1.0. At FTP, depletes in
    // ~89 min; at zone 2 (intensity ~0.2), depletes in ~5 h.
    hidden const ENERGY_DRAIN_RATE = 0.028;
    // Energy recovery: %/s at intensity = -1.0. 0% -> 100% in ~83 min.
    hidden const ENERGY_RECOVER_RATE = 0.02;
    // Per-update delta (in % points) needed to show a trend arrow.
    // Tuned for the new slower drain rates: max per-second delta is ~0.125%,
    // so a threshold of 0.05 catches meaningful changes without flickering.
    hidden const TREND_THRESHOLD = 0.05;
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
            myEnergy -= intensity * ENERGY_DRAIN_RATE * dt;
        } else if (intensity < 0.0) {
            myStamina += -intensity * RECOVER_RATE * dt;
            myEnergy += -intensity * ENERGY_RECOVER_RATE * dt;
        }
        if (myStamina < 0.0) { myStamina = 0.0; }
        if (myStamina > 100.0) { myStamina = 100.0; }
        if (myEnergy < 0.0) { myEnergy = 0.0; }
        if (myEnergy > 100.0) { myEnergy = 100.0; }

        // Display stamina is the bottleneck: whichever tank is lower.
        var displayStamina = myStamina < myEnergy ? myStamina : myEnergy;

        var trend = 0;
        if (displayStamina > myLastStamina + TREND_THRESHOLD) { trend = 1; }
        else if (displayStamina < myLastStamina - TREND_THRESHOLD) { trend = -1; }

        myLastStamina = displayStamina;
        myLastUpdateMs = nowMs;
        myHasHistory = true;

        // Trend sign baked into the value string so the layout font renders it (Bebas ships ASCII).
        var staminaText = displayStamina.format("%d");
        if (trend > 0) {
            staminaText = "+" + staminaText;
        } else if (trend < 0) {
            staminaText = "-" + staminaText;
        }

        logTick(effort, signalLabel(info), intensity,
                myStamina, myEnergy, displayStamina);

        var field = new Field(layoutKey, staminaText, "");
        if (displayStamina > 50.0) {
            field.setBackgroundColor(Graphics.COLOR_GREEN);
            field.setTextColor(Graphics.COLOR_BLACK);
            field.setLabelColor(Graphics.COLOR_LT_GRAY);
        } else if (displayStamina > 20.0) {
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

    // Returns "power" or "hr" for the active effort signal, or "?" when none.
    hidden function signalLabel(info as Activity.Info) as String {
        if (info has :currentPower && info.currentPower != null && info.currentPower > 0) {
            return "power";
        }
        if (info has :currentHeartRate && info.currentHeartRate != null && info.currentHeartRate > 0) {
            return "hr";
        }
        return "?";
    }

    // Returns [effort] (Number) or null when neither power nor HR is available.
    // Thresholds are resolved lazily and cached on the instance.
    hidden function resolveSignal(info as Activity.Info) as Array? {
        if (!myHaveThresholds) {
            var havePower = info has :currentPower && info.currentPower != null && info.currentPower > 0;
            var haveHr = info has :currentHeartRate && info.currentHeartRate != null && info.currentHeartRate > 0;

            if (havePower) {
                var pZones = getPowerZones();
                if (pZones != null && pZones.size() >= 6 && pZones[2] != null && pZones[5] != null
                    && pZones[2] > 0 && pZones[5] > pZones[2]) {
                    myAet = pZones[2].toFloat();
                    myAnt = pZones[5].toFloat();
                    myZones = pZones;
                    logInit("power", "powerZones", myAet, myAnt, myZones);
                } else {
                    var ftp = getFtp();
                    if (ftp > 0) {
                        myAet = ftp.toFloat() * 0.75;
                        myAnt = ftp.toFloat() * 1.20;
                        myZones = null;
                        logInit("power", "ftpFallback", myAet, myAnt, null);
                    } else {
                        havePower = false;
                    }
                }
                if (havePower) {
                    myHaveThresholds = true;
                }
            }

            if (!myHaveThresholds && haveHr) {
                var zones = getHrZones();
                if (zones != null && zones.size() >= 6 && zones[2] != null && zones[5] != null
                    && zones[2] > 0 && zones[5] > zones[2]) {
                    myAet = zones[2].toFloat();
                    myAnt = zones[5].toFloat();
                    myZones = zones;
                    logInit("hr", "hrZones", myAet, myAnt, myZones);
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

    // Returns the power zone thresholds [minZ1, maxZ1, maxZ2, maxZ3, maxZ4, maxZ5],
    // or null when the device/profile does not expose them.
    hidden function getPowerZones() as Array? {
        try {
            if (UserProfile has :getPowerZones) {
                return UserProfile.getPowerZones(Activity.SPORT_CYCLING);
            }
        } catch (ex) {
        }
        return null;
    }

    // Returns the HR zone thresholds [minZ1, maxZ1, maxZ2, maxZ3, maxZ4, maxZ5],
    // or null when the device/profile does not expose them.
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

    // Returns the precise zone number (Z1..Z5) the effort falls into, based on the
    // device's actual zone thresholds. Returns "?" when zones are unavailable
    // (FTP fallback) or effort is below zones[0] / above zones[5].
    hidden function zoneNumberForEffort(effort as Float) as String {
        if (myZones == null || myZones.size() < 6) {
            return "?";
        }
        if (effort < myZones[0]) { return "<Z1"; }
        if (effort < myZones[1]) { return "Z1"; }
        if (effort < myZones[2]) { return "Z2"; }
        if (effort < myZones[3]) { return "Z3"; }
        if (effort < myZones[4]) { return "Z4"; }
        if (effort < myZones[5]) { return "Z5"; }
        return ">Z5";
    }

    hidden function logInit(signal as String, source as String, aet as Float, ant as Float, zones as Array?) {
        var zoneInfo;
        if (zones != null && zones.size() >= 6) {
            zoneInfo = " zones=[" + zones[0] + "," + zones[1] + "," + zones[2] + ","
                + zones[3] + "," + zones[4] + "," + zones[5] + "]";
        } else {
            zoneInfo = " zones=none";
        }
        System.println("STAMINA_INIT signal=" + signal + " source=" + source
            + " aet=" + aet.format("%.1f") + " ant=" + ant.format("%.1f")
            + zoneInfo);
    }

    hidden function logTick(effort as Float, signal as String, intensity as Float,
                            wbal as Float, energy as Float, display as Float) {
        System.println("STAMINA_TICK signal=" + signal
            + " effort=" + effort.format("%.1f")
            + " zone=" + zoneNumberForEffort(effort)
            + " intensity=" + intensity.format("%.3f")
            + " wbal=" + wbal.format("%.2f")
            + " energy=" + energy.format("%.2f")
            + " display=" + display.format("%.2f"));
    }
}
