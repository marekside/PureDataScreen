import Toybox.Lang;
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class TotalAscentField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if (info has :totalAscent  && info.totalAscent  != null) {
            var value = info.totalAscent.format("%d"); // Convert m/s to km/h
            
            return new Field(layoutKey, value, "");
        }
        return new Field(layoutKey, "0", "");
    }
}