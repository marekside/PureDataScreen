import Toybox.Lang;
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.AntPlus;

class BikeRadarField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        var bikeRadar = new AntPlus.BikeRadar(null);
        var targets = bikeRadar.getRadarInfo();
        if (targets != null && targets.size() > 0) {
            var target = targets[0];
            var carSpeedKmh = target.speed * 3.6;

            if (carSpeedKmh == 0 && target.threat == AntPlus.THREAT_LEVEL_NO_THREAT) {
                bikeRadar = null;
                return new Field(layoutKey, "Free", "");
            }

            var value = carSpeedKmh;
            if (info has :currentSpeed && info.currentSpeed != null) {
                var mySpeedKmh = info.currentSpeed * 3.6;
                value = carSpeedKmh + mySpeedKmh;
            }

            var label = value.format("%d");
            if (target.threat == AntPlus.THREAT_LEVEL_VEHICLE_APPROACHING) {
                label = label + " >";
            } else if (target.threat == AntPlus.THREAT_LEVEL_VEHICLE_FAST_APPROACHING) {
                label = label + " >>";
            }

            var field = new Field(layoutKey, label, "");
            if (value > 60) {
                field.setBackgroundColor(Graphics.COLOR_RED);
                field.setTextColor(Graphics.COLOR_WHITE);
            } else {
                field.setBackgroundColor(Graphics.COLOR_YELLOW);
                field.setTextColor(Graphics.COLOR_BLACK);
            }

            bikeRadar = null;
            return field;
        } else {
            bikeRadar = null;
            return new Field(layoutKey, "N/A", "");
        }
    }
}
