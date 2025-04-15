import Toybox.Lang;
import Toybox.Activity;

class SpeedField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String) as Field {
        if (info has :currentSpeed && info.currentSpeed != null) {
            var speedKmh = info.currentSpeed * 3.6; // Convert m/s to km/h
            var roundedDecimalNumber = (Math.round(speedKmh * 10) / 10).format("%0.1f");
            var value = roundedDecimalNumber.substring(0, roundedDecimalNumber.find("."));
            var decimal = roundedDecimalNumber.substring(roundedDecimalNumber.find(".") + 1, roundedDecimalNumber.length());
            return new Field(layoutKey, value, decimal);
        }
        return new Field(layoutKey, "0", "0");
    }
}