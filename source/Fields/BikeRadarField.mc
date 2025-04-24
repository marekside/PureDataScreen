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
            var speedKmh = target.speed * 3.6; // Convert m/s to kmh
            var value = (Math.round(speedKmh * 10) / 10);

            if (value == 0) {
                return new Field(layoutKey, "Free" , "");
            }

            if (info has :currentSpeed && info.currentSpeed != null) {
                var mySpeedKmh = info.currentSpeed * 3.6; // Convert m/s to km/h
                var myRoundedDecimalNumber = (Math.round(speedKmh * 10) / 10);
                value = value + myRoundedDecimalNumber;
            }

            bikeRadar = null;
            return new Field(layoutKey, value.format("%d") , "");
        } else {
            bikeRadar = null;
            return new Field(layoutKey, "N/A", "");
        }
    }
}