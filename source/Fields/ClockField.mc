import Toybox.Lang;
import Toybox.Activity;
import Toybox.WatchUi;

class ClockField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        var today = System.getClockTime();
        var dateTimeValue = Lang.format(
            "$1$:$2$",
            [
                today.hour.format("%02d"),
                today.min.format("%02d")
            ]
        );

        return new Field(layoutKey, dateTimeValue, ""); 
    }
}