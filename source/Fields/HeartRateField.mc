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
            System.println("HeartRateField hr=" + hr + " colors=[" + colors[0] + "," + colors[1] + "," + colors[2] + "] zones=" + (myZones != null));
            var field = new Field(layoutKey, hr.toString(), "");
            field.setBackgroundColor(colors[0]);
            field.setTextColor(colors[1]);
            field.setLabelColor(colors[2]);
            return field;
        }
        return new Field(layoutKey, "0", "");
    }

    // Returns [bgColor, textColor, labelColor] for the given heart rate based on the user's
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

    // Returns [bg, text, label] colors for a zone index (0-based).
    // Zone 1 (Easy/Recovery) -> Blue,   white text, white label
    // Zone 2 (Endurance)      -> Green,  black text, gray  label
    // Zone 3 (Tempo)          -> Yellow, black text, gray  label
    // Zone 4 (Threshold)      -> Orange, white text, white label
    // Zone 5 (Maximum)        -> Red,    white text, white label
    hidden function zoneColors(zoneIndex as Number) as Array {
        var bg = zoneColor(zoneIndex);
        var fg = foregroundForBg(bg);
        var label = labelColorFor(bg);
        return [bg, fg, label];
    }

    hidden function zoneColor(zoneIndex as Number) as ColorType {
        var palette = [
            Graphics.COLOR_BLUE,
            Graphics.COLOR_GREEN,
            Graphics.COLOR_YELLOW,
            Graphics.COLOR_ORANGE,
            Graphics.COLOR_RED,
        ];
        System.println("zoneColor: BLUE=" + Graphics.COLOR_BLUE + " GREEN=" + Graphics.COLOR_GREEN + " YELLOW=" + Graphics.COLOR_YELLOW + " ORANGE=" + Graphics.COLOR_ORANGE + " RED=" + Graphics.COLOR_RED + " WHITE=" + Graphics.COLOR_WHITE);
        if (zoneIndex < 0 || zoneIndex >= palette.size()) {
            return Graphics.COLOR_GREEN;
        }
        return palette[zoneIndex];
    }

// Returns WHITE for the dark alert bgs (blue/orange/red/yellow), BLACK otherwise.
// Explicit color match — the luminance heuristic on HeartRateField is unreliable
// across devices whose color encoding (RGB565, AMOLED palette swaps) doesn't
// exactly match the 24-bit constants. COLOR_YELLOW (0xFFAA00) renders as a
// saturated orange-amber on Edge devices, so it needs the same white text.
    hidden function foregroundForBg(bg as ColorType) as ColorType {
        if (bg == Graphics.COLOR_BLUE || bg == Graphics.COLOR_ORANGE || bg == Graphics.COLOR_RED || bg == Graphics.COLOR_YELLOW || bg == Graphics.COLOR_BLACK) {
            return Graphics.COLOR_WHITE;
        }
        return Graphics.COLOR_BLACK;
    }

    hidden function labelColorFor(bg as ColorType) as ColorType {
        // White title for the dark alert bgs (blue/orange/red/yellow); LIGHT_GRAY otherwise.
        // Explicit color match — the luminance heuristic on HeartRateField is unreliable
        // across devices whose color encoding (RGB565, AMOLED palette swaps) doesn't
        // exactly match the 24-bit constants. COLOR_YELLOW (0xFFAA00) renders as a
        // saturated orange-amber on Edge devices, so it needs the same white label.
        if (bg == Graphics.COLOR_BLUE || bg == Graphics.COLOR_ORANGE || bg == Graphics.COLOR_RED || bg == Graphics.COLOR_YELLOW || bg == Graphics.COLOR_BLACK) {
            return Graphics.COLOR_WHITE;
        }
        return Graphics.COLOR_LT_GRAY;
    }

    // Approximate luminance test: extract R, G, B from a 24-bit RGB value and
    // check if the average is below 50%. Works regardless of color encoding.
    hidden function isDarkColor(c as ColorType) as Boolean {
        var r = (c >> 16) & 0xFF;
        var g = (c >> 8) & 0xFF;
        var b = c & 0xFF;
        // Luminance using standard ITU-R weights
        var lum = (r * 299 + g * 587 + b * 114) / 1000;
        return lum < 128;
    }

    // Used when zones are unavailable (older devices, missing permission).
    hidden function fallbackColors(hr as Number) as Array {
        if (hr > 160) {
            return [Graphics.COLOR_RED, Graphics.COLOR_WHITE, Graphics.COLOR_WHITE];
        } else if (hr > 130) {
            return [Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK, Graphics.COLOR_LT_GRAY];
        }
        return [Graphics.COLOR_GREEN, Graphics.COLOR_BLACK, Graphics.COLOR_LT_GRAY];
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