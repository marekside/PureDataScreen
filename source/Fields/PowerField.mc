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

    // Matches the fallback thresholds used when configured zones are unavailable.
    hidden const FALLBACK_LOW = 200;
    hidden const FALLBACK_HIGH = 300;

    function initialize() {
        BaseField.initialize();
    }

    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if (info has :currentPower && info.currentPower != null) {

            var averagePower = (info has :averagePower && info.averagePower != null) ? info.averagePower : null;
            updateAverageIndicator(dataField, layoutKey, info.currentPower, averagePower);

            var power = info.currentPower;
            var zoneIndex = getZoneIndexForPower(power);
            var colors = (zoneIndex <= 0)
                ? ZoneColorHelper.fallbackColors(power, FALLBACK_LOW, FALLBACK_HIGH)
                : ZoneColorHelper.colorsForZoneIndex(zoneIndex - 1);
            var zoneLabel = (zoneIndex > 0) ? zoneIndex.toString() : "";
            var field = new Field(layoutKey, power.toString(), zoneLabel);
            field.setBackgroundColor(colors[0]);
            field.setTextColor(colors[1]);
            field.setLabelColor(colors[2]);
            return field;
        }
        return new Field(layoutKey, "0", "");
    }

    // Returns the 1-based power zone index for the given power value.
    // 0 when power is below the user's configured Zone 1 minimum.
    // Zones are loaded from UserProfile on first call and cached in myZones.
    // Array layout: [minZ1, maxZ1, maxZ2, maxZ3, maxZ4, maxZ5]
    // Zone N covers [maxZ(N-1), maxZN), with zone 1 starting at minZ1.
    hidden function getZoneIndexForPower(power as Number) as Number {
        if (myZones == null) {
            myZones = loadZones();
        }

        if (myZones == null || myZones.size() < 6) {
            return ZoneColorHelper.fallbackZoneIndex(power, FALLBACK_LOW, FALLBACK_HIGH);
        }

        return ZoneColorHelper.zoneIndexFromZones(power, myZones);
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