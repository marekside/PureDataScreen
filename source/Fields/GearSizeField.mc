import Toybox.Lang;
import Toybox.Activity;
import Toybox.WatchUi;

class GearsSizeField extends BaseField {
    function initialize() {
        BaseField.initialize();
    }

    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        var frontDerailleurSize = "";
        var rearDerailleurSize = "";
        if(info has :frontDerailleurSize  && info.frontDerailleurSize  != null){
            frontDerailleurSize = info.frontDerailleurSize.toString();
        } 
        if(info has :rearDerailleurSize  && info.rearDerailleurSize  != null){
            rearDerailleurSize = info.rearDerailleurSize.toString();
        } 
        
        var derailleurSizeValue = Lang.format("$1$:$2$", [frontDerailleurSize, rearDerailleurSize]);
        if (frontDerailleurSize.equals("") && rearDerailleurSize.equals("")) {
            derailleurSizeValue = "0:0";
        }

        return new Field(layoutKey, derailleurSizeValue, ""); 
    }
}