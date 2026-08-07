import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class Field {
    public var Value = "";
    public var Decimal = "";
    public var Name = "";
    public var BackgroundColor = Graphics.COLOR_WHITE;
    public var TextColor = Graphics.COLOR_BLACK;

    public function initialize(name as String, value as String, decimal as String) {
        Name = name;
        Value = value;
        Decimal = decimal;
    }

    // Override to reserve the decimal label's screen space for custom graphics instead of text.
    public function hasCustomDrawing() as Boolean {
        return false;
    }

    // Override to draw custom graphics at (cx, cy); called after the layout/background has been drawn.
    public function draw(dc as Dc, cx as Numeric, cy as Numeric, size as Numeric, foregroundColor as ColorType) as Void {
        // No-op by default.
    }
}