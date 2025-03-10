import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class Field {
    public var Value = "";
    public var Decimal = "";

    public function initialize(value as String, decimal as String) {
        Value = value;
        Decimal = decimal;
    }
}