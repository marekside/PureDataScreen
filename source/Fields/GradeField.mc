import Toybox.Lang;
import Toybox.Activity;
import Toybox.WatchUi;

class GradeField extends BaseField {
    hidden var myPreviousAltitude = null;
    hidden var myPreviousDistance = null;
    hidden var myLastGrade = 0.0;

    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if (info has :altitude && info.altitude != null &&
            info has :elapsedDistance && info.elapsedDistance != null) {

            var altitude = info.altitude;
            var distance = info.elapsedDistance;

            if (myPreviousDistance != null) {
                var deltaDistance = distance - myPreviousDistance;
                // Only recompute once enough distance has accumulated, to avoid noisy spikes while nearly stationary.
                if (deltaDistance >= 30.0) {
                    myLastGrade = ((altitude - myPreviousAltitude) / deltaDistance) * 100.0;
                    myPreviousAltitude = altitude;
                    myPreviousDistance = distance;
                }
            } else {
                myPreviousAltitude = altitude;
                myPreviousDistance = distance;
            }

            return new Field(layoutKey, myLastGrade.format("%.0f") + "%", "");
        }
        return new Field(layoutKey, "N/A", "");
    }
}
