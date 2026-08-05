import Toybox.Lang;
import Toybox.Activity;
import Toybox.Math;
import Toybox.WatchUi;

class NavigationField extends BaseField {
    public function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        if (info has :distanceToNextPoint && info.distanceToNextPoint != null &&
            info has :bearing && info.bearing != null &&
            info has :currentHeading && info.currentHeading != null) {

            var distance = info.distanceToNextPoint;
            var value;
            if (distance < 1000) {
                value = distance.format("%d") + "m";
            } else {
                value = (distance / 1000).format("%0.1f") + "km";
            }

            var field = new Field(layoutKey, value, "");
            field.Angle = normalizeAngle(info.bearing - info.currentHeading);
            return field;
        } else {
            return new Field(layoutKey, "N/A", "");
        }
    }

    // Wraps a relative bearing to the (-PI, PI] range expected by the arrow drawing code.
    hidden function normalizeAngle(angle as Float) as Float {
        var twoPi = Math.PI * 2;
        while (angle > Math.PI) {
            angle -= twoPi;
        }
        while (angle <= -Math.PI) {
            angle += twoPi;
        }
        return angle;
    }
}
