import Toybox.Lang;
import Toybox.Activity;

class PowerField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String) as Field {
        if(info has :currentPower && info.currentPower != null){
            var value = info.currentPower.toString();
            return new Field(layoutKey, value, "");
        } else {
            return new Field(layoutKey, "0", "");
        }
    }
}