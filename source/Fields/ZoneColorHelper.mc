import Toybox.Lang;
import Toybox.Graphics;

// Shared zone-based coloring/lookup logic for HeartRateField and PowerField.
// Each field still owns its own zone-array loading (different UserProfile APIs)
// and its own fallback thresholds (HR: 130/160 bpm, Power: 200/300 W).
public class ZoneColorHelper {

    // Returns the 1-based zone index for `value` given a 6-element zones array
    // [minZ1, maxZ1, maxZ2, maxZ3, maxZ4, maxZ5]. 0 when below minZ1.
    public static function zoneIndexFromZones(value as Numeric, zones as Array) as Number {
        if (value < zones[0]) { return 0; }
        if (value < zones[1]) { return 1; }
        if (value < zones[2]) { return 2; }
        if (value < zones[3]) { return 3; }
        if (value < zones[4]) { return 4; }
        return 5;
    }

    // Approximate 3-band zone index (1, 3, or 5) for when configured zones are unavailable.
    public static function fallbackZoneIndex(value as Numeric, lowThreshold as Numeric, highThreshold as Numeric) as Number {
        if (value > highThreshold) {
            return 5;
        } else if (value > lowThreshold) {
            return 3;
        }
        return 1;
    }

    // Returns [bg, text, label] colors for a 0-based zone index (pass zoneIndex - 1 from the
    // 1-based lookups above). Zone 1 -> Blue, 2 -> Green, 3 -> Yellow, 4 -> Orange, 5 -> Red.
    public static function colorsForZoneIndex(zoneIndex as Number) as Array {
        var palette = [
            Graphics.COLOR_BLUE,
            Graphics.COLOR_GREEN,
            Graphics.COLOR_YELLOW,
            Graphics.COLOR_ORANGE,
            Graphics.COLOR_RED,
        ];
        var bg = (zoneIndex < 0 || zoneIndex >= palette.size()) ? Graphics.COLOR_GREEN : palette[zoneIndex];
        return [bg, foregroundForBg(bg), labelColorFor(bg)];
    }

    // Matches colorsForZoneIndex's palette (blue is only reachable via configured zones).
    public static function fallbackColors(value as Numeric, lowThreshold as Numeric, highThreshold as Numeric) as Array {
        if (value > highThreshold) {
            return [Graphics.COLOR_RED, Graphics.COLOR_WHITE, Graphics.COLOR_WHITE];
        } else if (value > lowThreshold) {
            return [Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK, Graphics.COLOR_LT_GRAY];
        }
        return [Graphics.COLOR_GREEN, Graphics.COLOR_BLACK, Graphics.COLOR_LT_GRAY];
    }

    // Explicit color match — device color encoding (RGB565, AMOLED palette swaps) makes a
    // luminance heuristic unreliable. COLOR_YELLOW (0xFFAA00) renders as saturated orange-amber
    // on Edge devices, so it needs the same white text/label as the other dark backgrounds.
    public static function foregroundForBg(bg as ColorType) as ColorType {
        if (bg == Graphics.COLOR_BLUE || bg == Graphics.COLOR_ORANGE || bg == Graphics.COLOR_RED || bg == Graphics.COLOR_YELLOW || bg == Graphics.COLOR_BLACK) {
            return Graphics.COLOR_WHITE;
        }
        return Graphics.COLOR_BLACK;
    }

    public static function labelColorFor(bg as ColorType) as ColorType {
        if (bg == Graphics.COLOR_BLUE || bg == Graphics.COLOR_ORANGE || bg == Graphics.COLOR_RED || bg == Graphics.COLOR_YELLOW || bg == Graphics.COLOR_BLACK) {
            return Graphics.COLOR_WHITE;
        }
        return Graphics.COLOR_LT_GRAY;
    }
}
