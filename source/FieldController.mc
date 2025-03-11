import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class FieldsController { 
    var myFieldTolayoutMapping = {} as Dictionary;
    var myFieldToValueMapping = {} as Dictionary;
    var myDataField = null as DataField;

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
            decimalViewText.setText("0"); 
        }
    }

    public function redrawFieldValue() as Void {
        var keys = myFieldToValueMapping.keys();
        for (var i = 0; i < keys.size(); i++) {
            var layoutResourceValue = myDataField.findDrawableById(keys[i] + WatchUi.loadResource(Rez.Strings.FIELD_VALUE_POSTFIX)) as Text;
            var layoutResourceDecimal = myDataField.findDrawableById(keys[i] + WatchUi.loadResource(Rez.Strings.FIELD_DECIMAL_POSTFIX)) as Text;
            var field = myFieldToValueMapping.get(keys[i]);

            if (field != null) {
                if (field.Decimal.equals("")) {
                    layoutResourceValue.locX = layoutResourceDecimal.locX + 3;
                }

                redrawField(layoutResourceValue, field.Value);
                redrawField(layoutResourceDecimal, field.Decimal);
            }
        }
    }

    hidden function redrawField(resource as Text, value as String) as Void {
        if (myDataField.getBackgroundColor() == Graphics.COLOR_BLACK) {
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
            var layoutResourceNameForValue = layoutKeys[i] + WatchUi.loadResource(Rez.Strings.FIELD_VALUE_POSTFIX);
            var layoutResourceNameForDecimal = layoutKeys[i] + WatchUi.loadResource(Rez.Strings.FIELD_DECIMAL_POSTFIX);
            var fieldToStore = null;

            var assignedFieldType = myFieldTolayoutMapping.get(layoutKeys[i]);
            switch (assignedFieldType) {
                case FieldTypes.FIELD_TYPE_SPEED:
                    if(info has :currentSpeed && info.currentSpeed != null) {
                        var speedKmh = info.currentSpeed * 3.6; // Convert m/s to km/h
                        var roundedDecimalNumber = (Math.round(speedKmh * 10) / 10).format("%0.1f"); // Round to one decimal place
                        var value = roundedDecimalNumber.substring(0, roundedDecimalNumber.find("."));
                        var decimal = roundedDecimalNumber.substring(roundedDecimalNumber.find(".")+1, roundedDecimalNumber.length());
                        fieldToStore = new Field(layoutKeys[i], value, decimal);
                    }
                    break;
                case FieldTypes.FIELD_TYPE_HEART_RATE:
                    if(info has :currentHeartRate && info.currentHeartRate != null){
                        var value = info.currentHeartRate.toString();
                        fieldToStore = new Field(layoutKeys[i], value, "");
                    }
                    break;
                case FieldTypes.FIELD_TYPE_POWER:
                    if(info has :currentPower && info.currentPower != null){
                        var value = info.currentPower.toString();
                        fieldToStore = new Field(layoutKeys[i], value, "");
                    }
                    break;
                case FieldTypes.FIELD_TYPE_DISTANCE:
                    if(info has :elapsedDistance && info.elapsedDistance != null){
                        var distanceKm = info.elapsedDistance / 1000; // Convert meters to kilometers
                        var roundedDecimalNumber = distanceKm.format("%0.1f");
                        var value = roundedDecimalNumber.substring(0, roundedDecimalNumber.find("."));
                        var decimal = roundedDecimalNumber.substring(roundedDecimalNumber.find(".")+1, roundedDecimalNumber.length());
                        fieldToStore = new Field(layoutKeys[i], value, decimal);
                    }
                    break;
                case FieldTypes.FIELD_TYPE_AVERAGESPEED:
                    if (info has :averageSpeed && info.averageSpeed != null) {
                        var averageSpeedKmh = info.averageSpeed * 3.6; // Convert m/s to km/h
                        var roundedDecimalNumber = (Math.round(averageSpeedKmh * 10) / 10).format("%0.1f"); // Round to one decimal place
                        var value = roundedDecimalNumber.substring(0, roundedDecimalNumber.find("."));
                        var decimal = roundedDecimalNumber.substring(roundedDecimalNumber.find(".")+1, roundedDecimalNumber.length());
                        fieldToStore = new Field(layoutKeys[i], value, decimal);
                    }
                    break;
                case FieldTypes.FIELD_TYPE_TOTALTIME:
                    if(info has :timerTime && info.timerTime != null){
                        var totalSeconds = (info.timerTime/1000);
                        var hours = (totalSeconds / 3600).toNumber(); // Calculate hours
                        var minutes = ((totalSeconds % 3600) / 60).toNumber(); // Calculate minutes
                        var seconds = (totalSeconds % 60).toNumber(); // Calculate seconds
                        if (hours == 0) {
                            var value = Lang.format("$1$:$2$", [minutes.format("%02d"), seconds.format("%02d")]);
                            fieldToStore = new Field(layoutKeys[i], value, "");
                        } else {
                            var value = Lang.format("$1$:$2$", [hours.format("%02d"), minutes.format("%02d")]);
                            fieldToStore = new Field(layoutKeys[i], value, "");
                        }
                    }   
                    break;
                case FieldTypes.FIELD_TYPE_CADENCE:
                    if(info has :currentCadence && info.currentCadence  != null){
                        var value = info.currentCadence .toString();
                        fieldToStore = new Field(layoutKeys[i], value, "");
                    }   
                    break;
                case FieldTypes.FIELD_TYPE_CALORIES:
                    if(info has :calories && info.calories != null){
                        var value = info.calories.toString();
                        fieldToStore = new Field(layoutKeys[i], value, "");
                    }
                    break;
                default:
                    break;
            }

            storeFieldValue(layoutKeys[i], fieldToStore);
        }
    }
}