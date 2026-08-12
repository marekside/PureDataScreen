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

    // Matches the fallback thresholds used when configured zones are unavailable.
    hidden const FALLBACK_LOW = 130;
    hidden const FALLBACK_HIGH = 160;

    function initialize() {
        BaseField.initialize();
    }

    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if (info has :currentHeartRate && info.currentHeartRate != null) {

            var averageHeartRate = (info has :averageHeartRate && info.averageHeartRate != null) ? info.averageHeartRate : null;
            updateAverageIndicator(dataField, layoutKey, info.currentHeartRate, averageHeartRate);

            var hr = info.currentHeartRate;
            var zoneIndex = getZoneIndexForHr(hr);
            var colors = (zoneIndex <= 0)
                ? ZoneColorHelper.fallbackColors(hr, FALLBACK_LOW, FALLBACK_HIGH)
                : ZoneColorHelper.colorsForZoneIndex(zoneIndex - 1);
            var zoneLabel = (zoneIndex > 0) ? zoneIndex.toString() : "";
            var field = new Field(layoutKey, hr.toString(), zoneLabel);
            field.setBackgroundColor(colors[0]);
            field.setTextColor(colors[1]);
            field.setLabelColor(colors[2]);
            return field;
        }
        return new Field(layoutKey, "0", "0");
    }

    // Returns the 1-based HR zone index for the given heart rate.
    // 0 when hr is below the user's configured Zone 1 minimum.
    // Zones are loaded from UserProfile on first call and cached in myZones.
    // Array layout: [minZ1, maxZ1, maxZ2, maxZ3, maxZ4, maxZ5]
    // Zone N covers [maxZ(N-1), maxZN), with zone 1 starting at minZ1.
    hidden function getZoneIndexForHr(hr as Number) as Number {
        if (myZones == null) {
            myZones = loadZones();
        }

        if (myZones == null || myZones.size() < 6) {
            return ZoneColorHelper.fallbackZoneIndex(hr, FALLBACK_LOW, FALLBACK_HIGH);
        }

        return ZoneColorHelper.zoneIndexFromZones(hr, myZones);
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