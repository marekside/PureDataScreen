import Toybox.Lang;
import Toybox.Activity;

class GearsIndexField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String) as Field {
        var frontDerailleurIndex = "";
        var rearDerailleurIndex = "";
        if(info has :frontDerailleurIndex  && info.frontDerailleurIndex  != null){
            frontDerailleurIndex = info.frontDerailleurIndex.toString();
        } 
        if(info has :rearDerailleurIndex  && info.rearDerailleurIndex  != null){
            rearDerailleurIndex = info.rearDerailleurIndex.toString();
        } 
    
        var deraillerIndexValue = Lang.format("$1$:$2$", [frontDerailleurIndex, rearDerailleurIndex]);
        if (frontDerailleurIndex.equals("") && rearDerailleurIndex.equals("")) {
            deraillerIndexValue = "0:0";
        }

        return new Field(layoutKey, deraillerIndexValue, ""); 
    }
}