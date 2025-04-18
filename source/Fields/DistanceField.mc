import Toybox.Lang;
import Toybox.Activity;
import Toybox.WatchUi;

class DistanceField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if(info has :elapsedDistance && info.elapsedDistance != null){
            var distanceKm = info.elapsedDistance / 1000; // Convert meters to kilometers
            var roundedDecimalNumber = distanceKm.format("%0.1f");
            var value = roundedDecimalNumber.substring(0, roundedDecimalNumber.find("."));
            var decimal = roundedDecimalNumber.substring(roundedDecimalNumber.find(".")+1, roundedDecimalNumber.length());
            return new Field(layoutKey, value, decimal);
        } else {
            return new Field(layoutKey, "0", "0");
        }
    }
}