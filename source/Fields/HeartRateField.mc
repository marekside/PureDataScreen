import Toybox.Lang;
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.WatchUi;

class HeartRateField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if (info has :currentHeartRate && info.currentHeartRate != null) {

            if (Application.Properties.getValue(WatchUi.loadResource(Rez.Strings.AVERAGE_INDICATOR_PROPERTY))
                && layoutKey.equals(WatchUi.loadResource(Rez.Strings.FIELD1))
                && info has :averageHeartRate
                && info.averageHeartRate != null) {

                if (info.averageHeartRate >= info.currentHeartRate) {
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

            var hr = info.currentHeartRate;
            var field = new Field(layoutKey, hr.toString(), "");
            if (hr > 160) {
                field.setBackgroundColor(Graphics.COLOR_RED);
                field.setTextColor(Graphics.COLOR_WHITE);
            } else if (hr > 130) {
                field.setBackgroundColor(Graphics.COLOR_YELLOW);
                field.setTextColor(Graphics.COLOR_BLACK);
            } else {
                field.setBackgroundColor(Graphics.COLOR_GREEN);
                field.setTextColor(Graphics.COLOR_BLACK);
            }
            return field;
        }
        return new Field(layoutKey, "0", "");
    }
}
