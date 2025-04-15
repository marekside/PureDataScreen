import Toybox.Lang;
import Toybox.Activity;

class BaseField {
    function computeField(info as Activity.Info, layoutKey as String) as Field {
        return new Field(layoutKey, "0", "0"); // Default implementation
    }
}