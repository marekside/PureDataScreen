import Toybox.Lang;
import Toybox.Activity;
import Toybox.WatchUi;

class NavigationField extends BaseField {
    function initialize() {
        BaseField.initialize();
    }

    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if (info has :distanceToNextPoint && info.distanceToNextPoint != null) {
            var distance = info.distanceToNextPoint;
            var value;
            if (distance < 1000) {
                value = distance.format("%d") + "m";
            } else {
                value = (distance / 1000).format("%0.1f") + "km";
            }
            return new Field(layoutKey, value, "");
        }
        return new Field(layoutKey, "N/A", "");
    }
}
