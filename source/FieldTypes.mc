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
        FIELD_TYPE_GEARS = 9,
        FIELD_TYPE_CLOCK = 10,
    }

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
            case FIELD_TYPE_GEARS:
                return WatchUi.loadResource(Rez.Strings.GEARS);
            case FIELD_TYPE_CLOCK:
                return WatchUi.loadResource(Rez.Strings.CLOCK);
            default:
                return "";
        }
    }
}