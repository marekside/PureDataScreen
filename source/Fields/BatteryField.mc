import Toybox.Lang;
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class BatteryField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        var stats = System.getSystemStats();
        var value = stats.battery.format("%d") + "%";
        return new Field(layoutKey, value, "");
    }
}