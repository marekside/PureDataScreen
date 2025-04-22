import Toybox.Lang;
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class AveragePowerField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if(info has :averagePower && info.averagePower != null){
            var value = info.averagePower.toString();
            return new Field(layoutKey, value, "");
        } else {
            return new Field(layoutKey, "0", "");
        }
    }
}