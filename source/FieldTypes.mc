import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

public class FieldTypes {
    enum {
        FIELD_TYPE_SPEED = 1,
        FIELD_TYPE_HEART_RATE = 2,
        FIELD_TYPE_POWER = 3,
        FIELD_TYPE_DISTANCE = 4,
        FIELD_TYPE_AVERAGESPEED = 5,
        FIELD_TYPE_TOTALTIME = 6,
        FIELD_TYPE_CADENCE = 7,
        FIELD_TYPE_CALORIES = 8,
    }

    // <string id="KPH">KPH</string>
    // <string id="KPHAVG">KPHAVG</string>
    // <string id="HR">HR</string>
    // <string id="PWR">PWR</string>
    // <string id="DISTANCE">DISTANCE</string>
    // <string id="TOTTIME">TOTTIME</string>
    // <string id="CADENCE">CADENCE</string>
    // <string id="CALORIES">CALORIES</string>

    public static function getFieldByType(fieldType as String) as String {
        switch (fieldType) {
            case FIELD_TYPE_SPEED:
                return WatchUi.loadResource(Rez.Strings.KPH);
            case FIELD_TYPE_HEART_RATE:
                return WatchUi.loadResource(Rez.Strings.HR);
            case FIELD_TYPE_POWER:
                return WatchUi.loadResource(Rez.Strings.PWR);
            case FIELD_TYPE_DISTANCE:
                return WatchUi.loadResource(Rez.Strings.DISTANCE);
            case FIELD_TYPE_AVERAGESPEED:
                return WatchUi.loadResource(Rez.Strings.KPHAVG);
            case FIELD_TYPE_TOTALTIME:
                return WatchUi.loadResource(Rez.Strings.TOTTIME);
            case FIELD_TYPE_CADENCE:
                return WatchUi.loadResource(Rez.Strings.CADENCE);
            case FIELD_TYPE_CALORIES:
                return WatchUi.loadResource(Rez.Strings.CALORIES);
            default:
                return "";
        }
    }
}