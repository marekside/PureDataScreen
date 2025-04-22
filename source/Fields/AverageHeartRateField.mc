import Toybox.Lang;
import Toybox.Activity;
import Toybox.WatchUi;

class AverageHeartRateField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if (info has :averageHeartRate  && info.averageHeartRate  != null) {
            return new Field(layoutKey, info.averageHeartRate .toString(), "");
        }
        return new Field(layoutKey, "0", "");
    }
}