import Toybox.Lang;
import Toybox.Activity;

class CaloriesField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String) as Field {
        if(info has :calories && info.calories != null){
            var value = info.calories.toString();
            return new Field(layoutKey, value, "");
        } else {
            return new Field(layoutKey, "0", "");
        }
    }
}