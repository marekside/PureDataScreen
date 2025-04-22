import Toybox.Lang;
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class SpeedField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if (info has :currentSpeed && info.currentSpeed != null) {
            var speedKmh = info.currentSpeed * 3.6; // Convert m/s to km/h
            var roundedDecimalNumber = (Math.round(speedKmh * 10) / 10).format("%0.1f");
            var value = roundedDecimalNumber.substring(0, roundedDecimalNumber.find("."));
            var decimal = roundedDecimalNumber.substring(roundedDecimalNumber.find(".") + 1, roundedDecimalNumber.length());

            if (Application.Properties.getValue(WatchUi.loadResource(Rez.Strings.AVERAGE_INDICATOR_PROPERTY)) 
                && layoutKey.equals(WatchUi.loadResource(Rez.Strings.FIELD1)) 
                && info has :averageSpeed 
                && info.averageSpeed != null) {
                
                if (info.averageSpeed >= info.currentSpeed) {
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

            return new Field(layoutKey, value, decimal);
        }
        return new Field(layoutKey, "0", "0");
    }
}