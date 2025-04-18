import Toybox.Lang;
import Toybox.Activity;
import Toybox.WatchUi;

class CadenceField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if(info has :currentCadence && info.currentCadence  != null){
            var value = info.currentCadence .toString();
            return new Field(layoutKey, value, "");
        } else {
            return new Field(layoutKey, "0", "");
        } 
    }
}