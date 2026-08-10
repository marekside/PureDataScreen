import Toybox.Lang;
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.UserProfile;
import Toybox.WatchUi;

class HeartRateField extends BaseField {
    // Cached HR zone thresholds from UserProfile.getHeartRateZones().
    // Array of 6 Numbers: [minZone1, maxZone1, maxZone2, maxZone3, maxZone4, maxZone5].
    // Null if the device/profile does not expose zones, in which case a hardcoded
    // fallback is used.
    hidden var myZones = null;

    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if (info has :currentHeartRate && info.currentHeartRate != null) {

            if (Application.Properties.getValue(WatchUi.loadResource(Rez.Strings.AVERAGE_INDICATOR_PROPERTY))
                && layoutKey.equals(WatchUi.loadResource(Rez.Strings.FIELD1))
                && info has :averageHeartRate
                && info.averageHeartRate != null) {

                if (info.averageHeartRate >= info.currentHeartRate) {
                    dataField.findDrawableById(WatchUi.loadResource(Rez.Strings.AVERAGE_UP_INDICATOR)).setVisible(false);
                    dataField.findDrawableById(WatchUi.loadResource(Rez.Strings.AVERAGE_DOWN_INDICATOR)).setVisible(true);
                } else {
                    dataField.findDrawableById(WatchUi.loadResource(Rez.Strings.AVERAGE_UP_INDICATOR)).setVisible(true);
                    dataField.findDrawableById(WatchUi.loadResource(Rez.Strings.AVERAGE_DOWN_INDICATOR)).setVisible(false);
                }
            } else if (layoutKey.equals(WatchUi.loadResource(Rez.Strings.FIELD1))){
                dataField.findDrawableById(WatchUi.loadResource(Rez.Strings.AVERAGE_UP_INDICATOR)).setVisible(false);
                dataField.findDrawableById(WatchUi.loadResource(Rez.Strings.AVERAGE_DOWN_INDICATOR)).setVisible(false);
            }

            var hr = info.currentHeartRate;
            var colors = getColorsForHr(hr);
            var field = new Field(layoutKey, hr.toString(), "");
            field.setBackgroundColor(colors[0]);
            field.setTextColor(colors[1]);
            return field;
        }
        return new Field(layoutKey, "0", "");
    }

    // Returns [bgColor, fgColor] for the given heart rate based on the user's
    // configured HR zones. Zones are loaded from UserProfile on first call.
    // Array layout: [minZ1, maxZ1, maxZ2, maxZ3, maxZ4, maxZ5]
    // Zone N covers [maxZ(N-1), maxZN), with zone 1 starting at minZ1.
    hidden function getColorsForHr(hr as Number) as Array {
        if (myZones == null) {
            myZones = loadZones();
        }

        if (myZones == null || myZones.size() < 6) {
            return fallbackColors(hr);
        }

        if (hr >= myZones[0] && hr < myZones[1]) {
            return zoneColors(0);
        } else if (hr >= myZones[1] && hr < myZones[2]) {
            return zoneColors(1);
        } else if (hr >= myZones[2] && hr < myZones[3]) {
            return zoneColors(2);
        } else if (hr >= myZones[3] && hr < myZones[4]) {
            return zoneColors(3);
        } else if (hr >= myZones[4]) {
            return zoneColors(4);
        }

        return fallbackColors(hr);
    }

    // Returns the bg/fg colors for a zone index (0-based).
    // Zone 1 (Easy/Recovery) -> Blue,    white text
    // Zone 2 (Endurance)      -> Green,   black text
    // Zone 3 (Tempo)          -> Yellow,  black text
    // Zone 4 (Threshold)      -> Orange,  white text
    // Zone 5 (Maximum)        -> Red,     white text
    hidden function zoneColors(zoneIndex as Number) as Array {
        var bg = zoneColor(zoneIndex);
        return [bg, foregroundForBg(bg)];
    }

    hidden function zoneColor(zoneIndex as Number) as ColorType {
        var palette = [
            Graphics.COLOR_BLUE,
            Graphics.COLOR_GREEN,
            Graphics.COLOR_YELLOW,
            Graphics.COLOR_ORANGE,
            Graphics.COLOR_RED,
        ];
        if (zoneIndex < 0 || zoneIndex >= palette.size()) {
            return Graphics.COLOR_GREEN;
        }
        return palette[zoneIndex];
    }

    hidden function foregroundForBg(bg as ColorType) as ColorType {
        if (bg == Graphics.COLOR_BLUE || bg == Graphics.COLOR_RED || bg == Graphics.COLOR_ORANGE) {
            return Graphics.COLOR_WHITE;
        }
        return Graphics.COLOR_BLACK;
    }

    // Used when zones are unavailable (older devices, missing permission).
    hidden function fallbackColors(hr as Number) as Array {
        if (hr > 160) {
            return [Graphics.COLOR_RED, Graphics.COLOR_WHITE];
        } else if (hr > 130) {
            return [Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK];
        }
        return [Graphics.COLOR_GREEN, Graphics.COLOR_BLACK];
    }

    // Loads the 6 HR zone thresholds from the user profile for the current sport.
    // Returns null when zones are unavailable.
    hidden function loadZones() as Array? {
        try {
            if (!(UserProfile has :getHeartRateZones)) {
                return null;
            }
            var sport = null;
            if (UserProfile has :getCurrentSport) {
                sport = UserProfile.getCurrentSport();
            }
            var zones = UserProfile.getHeartRateZones(sport);
            if (zones == null || zones.size() < 6) {
                return null;
            }
            return zones;
        } catch (ex) {
            return null;
        }
    }
}