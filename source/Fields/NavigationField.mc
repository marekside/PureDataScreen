import Toybox.Lang;
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Math;
import Toybox.WatchUi;

// Field data that also knows how to draw its own turn arrow, instead of FieldsController needing to know about it.
class NavigationFieldValue extends Field {
    hidden var myAngle;

    public function initialize(name as String, value as String, angle) {
        Field.initialize(name, value, "");
        myAngle = angle;
    }

    public function hasCustomDrawing() as Boolean {
        return myAngle != null;
    }

    // Draws a small triangle at (cx, cy), rotated to point at the relative bearing (0 = straight ahead).
    public function draw(dc as Dc, cx as Numeric, cy as Numeric, size as Numeric, foregroundColor as ColorType) as Void {
        if (myAngle == null) {
            return;
        }

        var points = [
            [0, -size],
            [-size * 0.6, size * 0.6],
            [size * 0.6, size * 0.6],
        ];
        var cosA = Math.cos(myAngle);
        var sinA = Math.sin(myAngle);
        var rotated = new [3];
        for (var i = 0; i < 3; i++) {
            var px = points[i][0];
            var py = points[i][1];
            rotated[i] = [cx + (px * cosA - py * sinA), cy + (px * sinA + py * cosA)];
        }

        dc.setColor(foregroundColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(rotated);
    }
}

class NavigationField extends BaseField {
    hidden var myCurrentSnappedDeg = 0.0;
    hidden var myPendingSnappedDeg = null;
    hidden var myPendingCount = 0;

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

            // Only display turn arrow within 300 meters of the turn point
            var angle = null;
            if (distance <= 300) {
                var rawAngle = normalizeAngle(info.bearing - info.currentHeading);
                var rawDeg = rawAngle * (180.0 / Math.PI);
                var snappedDeg = snapTo8Way(rawDeg);
                var stableDeg = filterAngle(snappedDeg);

                angle = stableDeg * (Math.PI / 180.0);
            }

            return new NavigationFieldValue(layoutKey, value, angle);
        } else {
            fieldStateReset();
            return new Field(layoutKey, "N/A", "");
        }
    }

    hidden function fieldStateReset() as Void {
        myCurrentSnappedDeg = 0.0;
        myPendingSnappedDeg = null;
        myPendingCount = 0;
    }

    // Snaps angle in degrees to one of 8 discrete directions with dead-band straight ahead
    hidden function snapTo8Way(deg as Float) as Float {
        if (deg <= 25.0 && deg >= -25.0) {
            return 0.0; // Straight ahead dead-band
        } else if (deg > 25.0 && deg <= 67.5) {
            return 45.0; // Slight Right
        } else if (deg > 67.5 && deg <= 112.5) {
            return 90.0; // Right
        } else if (deg > 112.5 && deg <= 157.5) {
            return 135.0; // Sharp Right
        } else if (deg > 157.5 || deg < -157.5) {
            return 180.0; // U-Turn
        } else if (deg >= -157.5 && deg < -112.5) {
            return -135.0; // Sharp Left
        } else if (deg >= -112.5 && deg < -67.5) {
            return -90.0; // Left
        } else {
            return -45.0; // Slight Left
        }
    }

    // Requires 2 consecutive seconds of a new angle before changing direction (prevents jitter)
    hidden function filterAngle(newSnappedDeg as Float) as Float {
        if (newSnappedDeg == myCurrentSnappedDeg) {
            myPendingSnappedDeg = null;
            myPendingCount = 0;
        } else {
            if (myPendingSnappedDeg != null && newSnappedDeg == myPendingSnappedDeg) {
                myPendingCount++;
                if (myPendingCount >= 2) {
                    myCurrentSnappedDeg = newSnappedDeg;
                    myPendingSnappedDeg = null;
                    myPendingCount = 0;
                }
            } else {
                myPendingSnappedDeg = newSnappedDeg;
                myPendingCount = 1;
            }
        }
        return myCurrentSnappedDeg;
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
