import Toybox.Lang;
import Toybox.Activity;

class HeartRateField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String) as Field {
        if (info has :currentHeartRate && info.currentHeartRate != null) {
            return new Field(layoutKey, info.currentHeartRate.toString(), "");
        }
        return new Field(layoutKey, "0", "");
    }
}