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
}