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
            decimalViewText.setText(""); 
        }
    }

    public function redrawFieldValue() as Void {
        var keys = myFieldToValueMapping.keys();
        for (var i = 0; i < keys.size(); i++) {
            var layoutResource = myDataField.findDrawableById(keys[i]) as Text;
            if (myDataField.getBackgroundColor() == Graphics.COLOR_BLACK) {
                    layoutResource.setColor(Graphics.COLOR_WHITE);
            } else {
                layoutResource.setColor(Graphics.COLOR_BLACK);
            }
            layoutResource.setText(myFieldToValueMapping.get(keys[i]));
        }
    }

    hidden function storeFieldValue(layoutResourceName as String, value as String) as Void {
        myFieldToValueMapping.put(layoutResourceName, value);
    }

    public function compute(info as Activity.Info) as Void { 
        var layoutKeys = myFieldTolayoutMapping.keys();
        for (var i = 0; i < layoutKeys.size(); i++) {
            var layoutResourceNameForValue = layoutKeys[i] + WatchUi.loadResource(Rez.Strings.FIELD_VALUE_POSTFIX);
            var layoutResourceNameForDecimal = layoutKeys[i] + WatchUi.loadResource(Rez.Strings.FIELD_DECIMAL_POSTFIX);
            var value = "0";
            var decimal = "";

            var assignedFieldType = myFieldTolayoutMapping.get(layoutKeys[i]);
            switch (assignedFieldType) {
                case FieldTypes.FIELD_TYPE_SPEED:
                    if(info has :currentSpeed && info.currentSpeed != null) {
                        var speedKmh = info.currentSpeed * 3.6; // Convert m/s to km/h
                        var roundedDecimalNumber = (Math.round(speedKmh * 10) / 10).format("%0.1f"); // Round to one decimal place
                        value = roundedDecimalNumber.substring(0, roundedDecimalNumber.find("."));
                        decimal = roundedDecimalNumber.substring(roundedDecimalNumber.find(".")+1, roundedDecimalNumber.length());
                    }
                    break;
                case FieldTypes.FIELD_TYPE_HEART_RATE:
                    if(info has :currentHeartRate && info.currentHeartRate != null){
                        value = info.currentHeartRate.toString();
                    }
                    break;
                case FieldTypes.FIELD_TYPE_POWER:
                    if(info has :currentPower && info.currentPower != null){
                        value = info.currentPower.toString();
                    }
                    break;
                case FieldTypes.FIELD_TYPE_DISTANCE:
                    if(info has :elapsedDistance && info.elapsedDistance != null){
                        var distanceKm = info.elapsedDistance / 1000; // Convert meters to kilometers
                        var roundedDecimalNumber = distanceKm.format("%0.1f");
                        value = roundedDecimalNumber.substring(0, roundedDecimalNumber.find("."));
                        decimal = roundedDecimalNumber.substring(roundedDecimalNumber.find(".")+1, roundedDecimalNumber.length());
                    }
                    break;
                case FieldTypes.FIELD_TYPE_AVERAGESPEED:
                    if (info has :averageSpeed && info.averageSpeed != null) {
                        var averageSpeedKmh = info.averageSpeed * 3.6; // Convert m/s to km/h
                        var roundedDecimalNumber = (Math.round(averageSpeedKmh * 10) / 10).format("%0.1f"); // Round to one decimal place
                        value = roundedDecimalNumber.substring(0, roundedDecimalNumber.find("."));
                        decimal = roundedDecimalNumber.substring(roundedDecimalNumber.find(".")+1, roundedDecimalNumber.length());
                    }
                    break;
                case FieldTypes.FIELD_TYPE_TOTALTIME:
                    if(info has :timerTime && info.timerTime != null){
                        var totalSeconds = (info.timerTime/1000);
                        var hours = (totalSeconds / 3600).toNumber(); // Calculate hours
                        var minutes = ((totalSeconds % 3600) / 60).toNumber(); // Calculate minutes
                        var seconds = (totalSeconds % 60).toNumber(); // Calculate seconds
                        if (hours == 0) {
                            value = Lang.format("$1$:$2$", [minutes.format("%02d"), seconds.format("%02d")]);
                        } else {
                            value = Lang.format("$1$:$2$", [hours.format("%02d"), minutes.format("%02d")]);
                        }
                    }   
                    break;
                case FieldTypes.FIELD_TYPE_CADENCE:
                    if(info has :currentCadence && info.currentCadence  != null){
                        value = info.currentCadence .toString();
                    }   
                    break;
                case FieldTypes.FIELD_TYPE_CALORIES:
                    if(info has :calories && info.calories != null){
                        value = info.calories.toString();
                    }
                    break;
                default:
                    break;
            }
            storeFieldValue(layoutResourceNameForValue, value);
            storeFieldValue(layoutResourceNameForDecimal, decimal);
        }
    }
}