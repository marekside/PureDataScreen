import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class Field {
    public var Value = "";
    public var Decimal = "";
    public var Name = "";
    public var TextColor = Graphics.COLOR_BLACK;
    public var BackgroundColor = Graphics.COLOR_TRANSPARENT;
    public var LabelColor = Graphics.COLOR_LT_GRAY;

    public function initialize(name as String, value as String, decimal as String) {
        Name = name;
        Value = value;
        Decimal = decimal;
    }

    public function setTextColor(color) as Void {
        TextColor = color;
    }

    public function setBackgroundColor(color) as Void {
        BackgroundColor = color;
    }

    public function setLabelColor(color) as Void {
        LabelColor = color;
    }

    public function hasCustomBackground() as Boolean {
        return BackgroundColor != Graphics.COLOR_TRANSPARENT;
    }
}
