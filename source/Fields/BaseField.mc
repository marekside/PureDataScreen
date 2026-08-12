import Toybox.Lang;
import Toybox.Activity;
import Toybox.WatchUi;

class BaseField {
    function computeField(info as Activity.Info, layoutKey as String, dataField as DataField) as Field {
        return new Field(layoutKey, "0", "0"); // Default implementation
    }

    // Toggles the FIELD1 average trend arrows based on current vs. average value.
    // No-op unless this field occupies the FIELD1 slot; hides both arrows when the
    // average-indicator setting is off or no average value is available.
    hidden function updateAverageIndicator(dataField as DataField, layoutKey as String, current as Numeric, average as Numeric?) as Void {
        if (!layoutKey.equals(WatchUi.loadResource(Rez.Strings.FIELD1))) {
            return;
        }

        var upIndicator = dataField.findDrawableById(WatchUi.loadResource(Rez.Strings.AVERAGE_UP_INDICATOR));
        var downIndicator = dataField.findDrawableById(WatchUi.loadResource(Rez.Strings.AVERAGE_DOWN_INDICATOR));
        var showTrend = average != null && Application.Properties.getValue(WatchUi.loadResource(Rez.Strings.AVERAGE_INDICATOR_PROPERTY));

        upIndicator.setVisible(showTrend && average < current);
        downIndicator.setVisible(showTrend && average >= current);
    }
}