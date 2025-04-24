import Toybox.Lang;
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.AntPlus;

class BikeRadarField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        var bikeRadar = new AntPlus.BikeRadar(null);
        var targets = bikeRadar.getRadarInfo(); // Get the targets from the Bike Radar
        if (targets != null && targets.size() > 0) {
            var target = targets[0]; // Get the first target
            var carSpeedKmh = target.speed * 3.6; // Convert m/s to kmh
            
            if (carSpeedKmh == 0 && target.threat == AntPlus.THREAT_LEVEL_NO_THREAT) {
                return new Field(layoutKey, "Free" , "");
            }

            var value = carSpeedKmh;
            if (info has :currentSpeed && info.currentSpeed != null) {
                var mySpeedKmh = info.currentSpeed * 3.6; // Convert m/s to km/h
                value = carSpeedKmh + mySpeedKmh;
            }

            if (target.threat == AntPlus.THREAT_LEVEL_VEHICLE_APPROACHING) {
                value = value.format("%d") + " >";
            } else if (target.threat == AntPlus.THREAT_LEVEL_VEHICLE_FAST_APPROACHING) {
                value = value.format("%d") + " >>";
            }

            bikeRadar = null;
            return new Field(layoutKey, value , "");
        } else {
            bikeRadar = null;
            return new Field(layoutKey, "N/A", "");
        }
    }
}