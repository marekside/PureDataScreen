import Toybox.Lang;
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class PowerField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if(info has :currentPower && info.currentPower != null){
            var value = info.currentPower.toString();

            if (Application.Properties.getValue(WatchUi.loadResource(Rez.Strings.AVERAGE_INDICATOR_PROPERTY)) 
                && layoutKey.equals(WatchUi.loadResource(Rez.Strings.FIELD1)) 
                && info has :averagePower 
                && info.averagePower != null) {
                
                if (info.averagePower >= info.currentPower) {
                    dataField.findDrawableById(WatchUi.loadResource(Rez.Strings.AVERAGE_UP_INDICATOR)).setVisible(false);
                    dataField.findDrawableById(WatchUi.loadResource(Rez.Strings.AVERAGE_DOWN_INDICATOR)).setVisible(true);
                } else {
                    dataField.findDrawableById(WatchUi.loadResource(Rez.Strings.AVERAGE_UP_INDICATOR)).setVisible(true);
                    dataField.findDrawableById(WatchUi.loadResource(Rez.Strings.AVERAGE_DOWN_INDICATOR)).setVisible(false);
                }
            } else if (layoutKey.equals(WatchUi.loadResource(Rez.Strings.FIELD1))){
                dataField.findDrawableById(WatchUi.loadResource(Rez.Strings.AVERAGE_UP_INDICATOR)).setVisible(false);
                dataField.findDrawableById(WatchUi.loadResource(Rez.Strings.AVERAGE_DOWN_INDICATOR)).setVisible(false);
            }

            return new Field(layoutKey, value, "");
        } else {
            return new Field(layoutKey, "0", "");
        }
    }
}