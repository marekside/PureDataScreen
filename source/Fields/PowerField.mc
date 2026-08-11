import Toybox.Lang;
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.UserProfile;
import Toybox.WatchUi;

class PowerField extends BaseField {
    // Cached power zone thresholds from UserProfile.getPowerZones().
    // Array of 6 Numbers: [minZone1, maxZone1, maxZone2, maxZone3, maxZone4, maxZone5].
    // Null if the device/profile does not expose zones, in which case a hardcoded
    // fallback is used.
    hidden var myZones = null;

    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if (info has :currentPower && info.currentPower != null) {

            if (Application.Properties.getValue(WatchUi.loadResource(Rez.Strings.AVERAGE_INDICATOR_PROPERTY))
                && layoutKey.equals(WatchUi.loadResource(Rez.Strings.FIELD1))
                && info has :averagePower
                && info.averagePower != null) {

                if (info.averagePower >= info.currentPower) {
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

            var power = info.currentPower;
            var colors = getColorsForPower(power);
            var field = new Field(layoutKey, power.toString(), "");
            field.setBackgroundColor(colors[0]);
            field.setTextColor(colors[1]);
            field.setLabelColor(colors[2]);
            return field;
        }
        return new Field(layoutKey, "0", "");
    }

    // Returns [bgColor, textColor, labelColor] for the given power value based on the user's
    // configured power zones. Zones are loaded from UserProfile on first call.
    // Array layout: [minZ1, maxZ1, maxZ2, maxZ3, maxZ4, maxZ5]
    // Zone N covers [maxZ(N-1), maxZN), with zone 1 starting at minZ1.
    hidden function getColorsForPower(power as Number) as Array {
        if (myZones == null) {
            myZones = loadZones();
        }

        if (myZones == null || myZones.size() < 6) {
            return fallbackColors(power);
        }

        if (power >= myZones[0] && power < myZones[1]) {
            return zoneColors(0);
        } else if (power >= myZones[1] && power < myZones[2]) {
            return zoneColors(1);
        } else if (power >= myZones[2] && power < myZones[3]) {
            return zoneColors(2);
        } else if (power >= myZones[3] && power < myZones[4]) {
            return zoneColors(3);
        } else if (power >= myZones[4]) {
            return zoneColors(4);
        }

        return fallbackColors(power);
    }

    // Returns [bg, text, label] colors for a zone index (0-based).
    // Zone 1 (Active Recovery) -> Blue,   white text, white label
    // Zone 2 (Endurance)       -> Green,  black text, gray  label
    // Zone 3 (Tempo)           -> Yellow, black text, gray  label
    // Zone 4 (Threshold)       -> Orange, white text, white label
    // Zone 5 (VO2 Max)         -> Red,    white text, white label
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
        if (zoneIndex < 0 || zoneIndex >= palette.size()) {
            return Graphics.COLOR_GREEN;
        }
        return palette[zoneIndex];
    }

    hidden function foregroundForBg(bg as ColorType) as ColorType {
        // White text on the dark alert bgs. COLOR_YELLOW (0xFFAA00) renders as a
        // saturated orange-amber on Edge devices, so it needs the same white text.
        if (bg == Graphics.COLOR_BLUE || bg == Graphics.COLOR_RED || bg == Graphics.COLOR_ORANGE || bg == Graphics.COLOR_YELLOW) {
            return Graphics.COLOR_WHITE;
        }
        return Graphics.COLOR_BLACK;
    }

    // White title for dark bgs, LIGHT_GRAY otherwise. COLOR_YELLOW (0xFFAA00) renders
    // as a saturated orange-amber on Edge devices, so it needs the same white label.
    hidden function labelColorFor(bg as ColorType) as ColorType {
        if (bg == Graphics.COLOR_RED || bg == Graphics.COLOR_ORANGE || bg == Graphics.COLOR_BLUE || bg == Graphics.COLOR_YELLOW || bg == Graphics.COLOR_BLACK) {
            return Graphics.COLOR_WHITE;
        }
        return Graphics.COLOR_LT_GRAY;
    }

    // Used when zones are unavailable (older devices, missing permission).
    hidden function fallbackColors(power as Number) as Array {
        if (power > 300) {
            return [Graphics.COLOR_RED, Graphics.COLOR_WHITE, Graphics.COLOR_WHITE];
        } else if (power > 200) {
            return [Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK, Graphics.COLOR_LT_GRAY];
        }
        return [Graphics.COLOR_GREEN, Graphics.COLOR_BLACK, Graphics.COLOR_LT_GRAY];
    }

    // Loads the 6 power zone thresholds from the user profile for cycling.
    // Returns null when zones are unavailable.
    hidden function loadZones() as Array? {
        try {
            if (!(UserProfile has :getPowerZones)) {
                return null;
            }
            var zones = UserProfile.getPowerZones(Activity.SPORT_CYCLING);
            if (zones == null || zones.size() < 6) {
                return null;
            }
            return zones;
        } catch (ex) {
            return null;
        }
    }
}