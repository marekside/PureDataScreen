import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.AntPlus;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;

class FieldsController { 
    var myFieldTolayoutMapping = {} as Dictionary;
    var myFieldToValueMapping = {} as Dictionary;
    var myDataField = null as DataField;

    hidden var fieldStrategyMap = {
        FieldTypes.FIELD_TYPE_SPEED => new SpeedField(),
        FieldTypes.FIELD_TYPE_HEART_RATE => new HeartRateField(),
        FieldTypes.FIELD_TYPE_POWER => new PowerField(),
        FieldTypes.FIELD_TYPE_DISTANCE => new DistanceField(),
        FieldTypes.FIELD_TYPE_AVERAGESPEED => new AverageSpeedField(),
        FieldTypes.FIELD_TYPE_TOTALTIME => new TotalTimeField(),
        FieldTypes.FIELD_TYPE_CADENCE => new CadenceField(),
        FieldTypes.FIELD_TYPE_CALORIES => new CaloriesField(),
        FieldTypes.FIELD_TYPE_GEARS => new GearsIndexField(),
        FieldTypes.FIELD_TYPE_CLOCK => new ClockField(),
        FieldTypes.FIELD_TYPE_GEARSIZE => new GearsSizeField(),
        FieldTypes.FIELD_TYPE_PWRAVG => new AveragePowerField(),
        FieldTypes.FIELD_TYPE_HRAVG => new AverageHeartRateField(),
        FieldTypes.FIELD_TYPE_BATTERY => new BatteryField(),
        FieldTypes.FIELD_TYPE_RADAR => new BikeRadarField(),
        FieldTypes.FIELD_TYPE_CLIMB => new TotalAscentField(),
        FieldTypes.FIELD_TYPE_NAVIGATION => new NavigationField(),
        FieldTypes.FIELD_TYPE_GRADE => new GradeField(),
        FieldTypes.FIELD_TYPE_STAMINA => new StaminaField(),
        // Add other field types and their strategies here...
    } as Dictionary;

    public function initialize(dataField as DataField) {
        myDataField = dataField;
        myFieldTolayoutMapping = {};
        myFieldToValueMapping = {};
    }

    public function initializeField(layoutResourceName as String, fieldType as String) as Void {
        var layoutResourceNameView = myDataField.findDrawableById(layoutResourceName) as Text;
        layoutResourceNameView.locY = layoutResourceNameView.locY - 16;
        layoutResourceNameView.setText(FieldTypes.getFieldByType(fieldType));
        myFieldTolayoutMapping.put(layoutResourceName, fieldType);

        var valueLayoutResourceName = layoutResourceName + WatchUi.loadResource(Rez.Strings.FIELD_VALUE_POSTFIX);
        var valueView = myDataField.findDrawableById(valueLayoutResourceName);
        var valueViewText;
        if (valueView != null) {
            valueViewText = valueView as Text;
            valueViewText.locY = valueViewText.locY - 5;
            valueViewText.setText("0"); 
        }

        var decimalLayoutResourceName = layoutResourceName + WatchUi.loadResource(Rez.Strings.FIELD_DECIMAL_POSTFIX);
        var decimalView = myDataField.findDrawableById(decimalLayoutResourceName);
        var decimalViewText;
        if (decimalView != null) {
            decimalViewText = decimalView as Text;
            decimalViewText.locY = decimalViewText.locY - 5;
            decimalViewText.setText(""); 
        }
    }

    public function redrawFieldValue() as Void {
        var keys = myFieldToValueMapping.keys();
        for (var i = 0; i < keys.size(); i++) {
            var layoutResourceValue = myDataField.findDrawableById(keys[i] + WatchUi.loadResource(Rez.Strings.FIELD_VALUE_POSTFIX)) as Text;
            var layoutResourceDecimal = myDataField.findDrawableById(keys[i] + WatchUi.loadResource(Rez.Strings.FIELD_DECIMAL_POSTFIX)) as Text;
            var field = myFieldToValueMapping.get(keys[i]);

            if (field != null) {
                if (!field.hasCustomDrawing() && field.Decimal.equals("")) {
                    layoutResourceValue.locX = layoutResourceDecimal.locX + 2;
                }

                redrawField(layoutResourceValue, field.Value, field.TextColor);
                redrawField(layoutResourceDecimal, field.Decimal, field.TextColor);
            }
        }
    }

    // Paints per-field alert backgrounds as full field-quadrant rectangles, derived from
    // the same grid coordinates used in drawables.xml (WahooLayout16 divides the bottom
    // half into 3 rows of 20% by 2 cols; WahooLayout14 divides it into 2 rows of 25%
    // by 2 cols; FIELD1 always occupies the top half). Must be called AFTER View.onUpdate(dc);
    // each alert rect covers the labels in its cell, so labels are re-drawn on top.
    public function paintFieldBackgrounds(dc as Dc) as Void {
        var screenW = dc.getWidth();
        var screenH = dc.getHeight();
        var isLayout16 = myFieldTolayoutMapping.hasKey("FIELD6");

        var keys = myFieldToValueMapping.keys();
        for (var i = 0; i < keys.size(); i++) {
            var field = myFieldToValueMapping.get(keys[i]);
            if (field == null || field.BackgroundColor == Graphics.COLOR_TRANSPARENT) {
                continue;
            }

            var rect = getFieldRect(keys[i], isLayout16, screenW, screenH);
            if (rect == null) {
                continue;
            }

            dc.setColor(field.BackgroundColor, field.BackgroundColor);
            dc.fillRectangle(rect[0], rect[1], rect[2], rect[3]);

            // Re-draw the field's labels on top of the alert bg fill.
            redrawFieldDrawables(keys[i], dc);
        }
    }

    // Returns [x, y, width, height] in pixels for a field, or null if the field is not part of the active layout.
    hidden function getFieldRect(fieldKey as String, isLayout16 as Boolean, screenW as Numeric, screenH as Numeric) as Array? {
        var percentages = isLayout16 ? {
            "FIELD1" => [0.0, 0.0, 1.0, 0.4],
            "FIELD2" => [0.0, 0.4, 0.5, 0.2],
            "FIELD3" => [0.5, 0.4, 0.5, 0.2],
            "FIELD4" => [0.0, 0.6, 0.5, 0.2],
            "FIELD5" => [0.5, 0.6, 0.5, 0.2],
            "FIELD6" => [0.0, 0.8, 0.5, 0.2],
            "FIELD7" => [0.5, 0.8, 0.5, 0.2],
        } as Dictionary : {
            "FIELD1" => [0.0, 0.0, 1.0, 0.5],
            "FIELD2" => [0.0, 0.5, 0.5, 0.25],
            "FIELD3" => [0.5, 0.5, 0.5, 0.25],
            "FIELD4" => [0.0, 0.75, 0.5, 0.25],
            "FIELD5" => [0.5, 0.75, 0.5, 0.25],
        } as Dictionary;

        if (!percentages.hasKey(fieldKey)) {
            return null;
        }

        var p = percentages.get(fieldKey);
        return [(p[0] * screenW).toNumber(), (p[1] * screenH).toNumber(), (p[2] * screenW).toNumber(), (p[3] * screenH).toNumber()];
    }

    hidden function redrawFieldDrawables(fieldKey as String, dc as Dc) as Void {
        var label = myDataField.findDrawableById(fieldKey);
        if (label != null) {
            label.draw(dc);
        }
        var valueLabel = myDataField.findDrawableById(fieldKey + WatchUi.loadResource(Rez.Strings.FIELD_VALUE_POSTFIX));
        if (valueLabel != null) {
            valueLabel.draw(dc);
        }
        var decimalLabel = myDataField.findDrawableById(fieldKey + WatchUi.loadResource(Rez.Strings.FIELD_DECIMAL_POSTFIX));
        if (decimalLabel != null) {
            decimalLabel.draw(dc);
        }
    }

    // Must be called after View.onUpdate(dc), otherwise the background/layout draw would paint over any custom graphics.
    public function drawFieldGraphics(dc as Dc) as Void {
        var foregroundColor = myDataField.getBackgroundColor() == Graphics.COLOR_BLACK ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;

        var keys = myFieldToValueMapping.keys();
        for (var i = 0; i < keys.size(); i++) {
            var field = myFieldToValueMapping.get(keys[i]);
            if (field != null && field.hasCustomDrawing()) {
                var valueLabel = myDataField.findDrawableById(keys[i] + WatchUi.loadResource(Rez.Strings.FIELD_VALUE_POSTFIX)) as Text;
                var fontResource = keys[i].equals("FIELD1") ? Rez.Fonts.Bebas_300 : Rez.Fonts.Bebas_100;
                var font = WatchUi.loadResource(fontResource);

                var textWidth = dc.getTextWidthInPixels(field.Value, font);
                var fontHeight = dc.getFontHeight(font);

                var size = keys[i].equals("FIELD1") ? 18 : 10;
                var cx = valueLabel.locX - textWidth - size - 8;
                var cy = valueLabel.locY + (fontHeight / 3);

                field.draw(dc, cx, cy, size, foregroundColor);
            }
        }
    }

    hidden function redrawField(resource as Text, value as String, textColor as ColorType) as Void {
        if (textColor != null && textColor != Graphics.COLOR_TRANSPARENT) {
            resource.setColor(textColor);
        } else if (myDataField.getBackgroundColor() == Graphics.COLOR_BLACK) {
            resource.setColor(Graphics.COLOR_WHITE);
        } else {
            resource.setColor(Graphics.COLOR_BLACK);
        }

        resource.setText(value);
    }

    hidden function storeFieldValue(layoutResourceName as String, value as Field) as Void {
        myFieldToValueMapping.put(layoutResourceName, value);
    }

    public function compute(info as Activity.Info) as Void {
        var layoutKeys = myFieldTolayoutMapping.keys();
        for (var i = 0; i < layoutKeys.size(); i++) {
            var layoutKey = layoutKeys[i];
            var assignedFieldType = myFieldTolayoutMapping.get(layoutKey);
            var strategy = fieldStrategyMap.get(assignedFieldType);

            var fieldToStore;
            if (strategy != null) {
                fieldToStore = strategy.computeField(info, layoutKey, myDataField);
            } else {
                fieldToStore = new Field(layoutKey, "0", "0"); // Default fallback
            }

            storeFieldValue(layoutKey, fieldToStore);
        }
    }

    public function isSourceChanged() as Boolean {
        for (var i = 1; i <= 7; i++) {
            var propertyName = "field" + i;
            var fieldToValuePropertyName = "FIELD" + i;
            var valueForProperty = Application.Properties.getValue(propertyName);
            var currentValueForProperty = myFieldTolayoutMapping.get(fieldToValuePropertyName);
            if (currentValueForProperty!= null && !valueForProperty.equals(currentValueForProperty)) {
                return true;
            }
        }
        return false;
    }
}