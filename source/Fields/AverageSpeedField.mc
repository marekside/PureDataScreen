import Toybox.Lang;
import Toybox.Activity;
import Toybox.WatchUi;

class AverageSpeedField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if (info has :averageSpeed && info.averageSpeed != null) {
            var averageSpeedKmh = info.averageSpeed * 3.6; // Convert m/s to km/h
            var roundedDecimalNumber = (Math.round(averageSpeedKmh * 10) / 10).format("%0.1f"); // Round to one decimal place
            var value = roundedDecimalNumber.substring(0, roundedDecimalNumber.find("."));
            var decimal = roundedDecimalNumber.substring(roundedDecimalNumber.find(".")+1, roundedDecimalNumber.length());
            return new Field(layoutKey, value, decimal);
        } else {
            return new Field(layoutKey, "0", "0");
        }
    }
}