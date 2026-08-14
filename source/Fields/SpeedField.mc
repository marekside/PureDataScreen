import Toybox.Lang;
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class SpeedField extends BaseField {
    function initialize() {
        BaseField.initialize();
    }

    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if (info has :currentSpeed && info.currentSpeed != null) {
            var speedKmh = info.currentSpeed * 3.6; // Convert m/s to km/h
            var roundedDecimalNumber = (Math.round(speedKmh * 10) / 10).format("%0.1f");
            var value = roundedDecimalNumber.substring(0, roundedDecimalNumber.find("."));
            var decimal = roundedDecimalNumber.substring(roundedDecimalNumber.find(".") + 1, roundedDecimalNumber.length());

            var averageSpeed = (info has :averageSpeed && info.averageSpeed != null) ? info.averageSpeed : null;
            updateAverageIndicator(dataField, layoutKey, speedKmh, (averageSpeed != null) ? averageSpeed * 3.6 : null);

            return new Field(layoutKey, value, decimal);
        }
        return new Field(layoutKey, "0", "0");
    }
}