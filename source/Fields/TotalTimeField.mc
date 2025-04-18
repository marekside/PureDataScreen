import Toybox.Lang;
import Toybox.Activity;
import Toybox.WatchUi;

class TotalTimeField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if(info has :timerTime && info.timerTime != null){
            var totalSeconds = (info.timerTime/1000);
            var hours = (totalSeconds / 3600).toNumber(); // Calculate hours
            var minutes = ((totalSeconds % 3600) / 60).toNumber(); // Calculate minutes
            var seconds = (totalSeconds % 60).toNumber(); // Calculate seconds
            var value;
            if (hours == 0) {
                value = Lang.format("$1$:$2$", [minutes.format("%02d"), seconds.format("%02d")]);
                return new Field(layoutKey, value, "");
            } else {
                value = Lang.format("$1$:$2$", [hours.format("%02d"), minutes.format("%02d")]);
                return new Field(layoutKey, value, "");
            }
        }
        return new Field(layoutKey, "0", "0"); 
    }
}