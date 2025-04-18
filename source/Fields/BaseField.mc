import Toybox.Lang;
import Toybox.Activity;
import Toybox.WatchUi;

class BaseField {
    function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        return new Field(layoutKey, "0", "0"); // Default implementation
    }
}