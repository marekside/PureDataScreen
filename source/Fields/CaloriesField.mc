import Toybox.Lang;
import Toybox.Activity;
import Toybox.WatchUi;

class CaloriesField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if(info has :calories && info.calories != null){
            var value = info.calories.toString();
            return new Field(layoutKey, value, "");
        } else {
            return new Field(layoutKey, "0", "");
        }
    }
}