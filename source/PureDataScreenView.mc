import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class PureDataScreenView extends WatchUi.DataField {

    hidden var mCurrentSpeed as String;
    hidden var mCurrentSpeedDecimal as String;
    hidden var mHeartRate as String;
    hidden var mPower3s as String;
    hidden var mDistance as String;
    hidden var mElapsedTime as String;
    hidden var mCurrentCadence as String;
    hidden var mCalories as String;
    hidden var mActiveLayoutConfiguration as Number;
    
    
    function initialize() {
        DataField.initialize();
        mCurrentSpeed = "n/a";
        mHeartRate = "n/a";
        mPower3s = "n/a";
        mDistance = "n/a";
        mElapsedTime = "n/a";
        mCurrentCadence = "n/a";
        mCalories = "n/a";
        mCurrentSpeedDecimal = "n/a";
        mActiveLayoutConfiguration = 1;
        readSettings();
    }   

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
        switch (mActiveLayoutConfiguration) {
            case  1: 
                View.setLayout(Rez.Layouts.WahooLayout16(dc));
                initializeField(WatchUi.loadResource(Rez.Strings.KPH));
                initializeField(WatchUi.loadResource(Rez.Strings.HR));
                initializeField(WatchUi.loadResource(Rez.Strings.PWR));
                initializeField(WatchUi.loadResource(Rez.Strings.DISTANCE));
                initializeField(WatchUi.loadResource(Rez.Strings.TOTTIME));
                initializeField(WatchUi.loadResource(Rez.Strings.CADENCE));
                initializeField(WatchUi.loadResource(Rez.Strings.CALORIES));
                break;
            case  2:
                View.setLayout(Rez.Layouts.WahooLayout14(dc));
                initializeField(WatchUi.loadResource(Rez.Strings.KPH));
                initializeField(WatchUi.loadResource(Rez.Strings.HR));
                initializeField(WatchUi.loadResource(Rez.Strings.DISTANCE));
                initializeField(WatchUi.loadResource(Rez.Strings.TOTTIME));
                initializeField(WatchUi.loadResource(Rez.Strings.CALORIES));
                break;
            default:
                break;
        }
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        // See Activity.Info in the documentation for available information.
        if(info has :currentSpeed){
            if(info.currentSpeed != null){
                var speedKmh = info.currentSpeed * 3.6; // Convert m/s to km/h
                var roundedDecimalNumber = (Math.round(speedKmh * 10) / 10).format("%0.1f"); // Round to one decimal place
                mCurrentSpeed = roundedDecimalNumber.substring(0, roundedDecimalNumber.find("."));
                mCurrentSpeedDecimal = roundedDecimalNumber.substring(roundedDecimalNumber.find(".")+1, roundedDecimalNumber.length());
            } else {
                mCurrentSpeed = "n/a";
            }
        }

        if(info has :currentHeartRate ){
            if(info.currentHeartRate != null){
                mHeartRate = info.currentHeartRate.toString();
            } else {
                mHeartRate = "n/a";
            }
        }

        if(info has :currentPower ){
            if(info.currentPower != null){
                mPower3s = info.currentPower.toString();
            } else {
                mPower3s = "n/a";
            }
        }

        if(info has :elapsedDistance){
            if(info.elapsedDistance != null){
                var distanceKm = info.elapsedDistance / 1000; // Convert meters to kilometers
                mDistance = distanceKm.format("%0.2f");
            } else {
                mDistance = "n/a";
            }
        }

        if(info has :timerTime){
            if(info.timerTime != null){
                var totalSeconds = (info.timerTime/1000);

                var hours = (totalSeconds / 3600).toNumber(); // Calculate hours
                var minutes = ((totalSeconds % 3600) / 60).toNumber(); // Calculate minutes
                var seconds = (totalSeconds % 60).toNumber(); // Calculate seconds
                if (hours == 0) {
                    mElapsedTime = Lang.format("$1$:$2$", [minutes.format("%02d"), seconds.format("%02d")]);
                } else {
                    mElapsedTime = Lang.format("$1$:$2$", [hours.format("%02d"), minutes.format("%02d")]);
                }
            } else {
                mElapsedTime = "n/a";
            }
        }

        if(info has :currentCadence ){
            if(info.currentCadence  != null){
                mCurrentCadence = info.currentCadence .toString();
            } else {
                mCurrentCadence = "n/a";
            }
        }

        if(info has :calories){
            if(info.calories != null){
                mCalories = info.calories.toString();
            } else {
                mCalories = "n/a";
            }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        (View.findDrawableById("Background") as Text).setColor(getBackgroundColor());
        
        if (isSettingsChanged()) {
            readSettings();
            onLayout(dc);
        }

        switch (mActiveLayoutConfiguration) {
            case  1: 
                setFieldValue(WatchUi.loadResource(Rez.Strings.KPH), "value", mCurrentSpeed);
                setFieldValue(WatchUi.loadResource(Rez.Strings.KPH), "decimal", mCurrentSpeedDecimal);
                setFieldValue(WatchUi.loadResource(Rez.Strings.HR), "value", mHeartRate);
                setFieldValue(WatchUi.loadResource(Rez.Strings.PWR), "value", mPower3s);
                setFieldValue(WatchUi.loadResource(Rez.Strings.DISTANCE), "value", mDistance);
                setFieldValue(WatchUi.loadResource(Rez.Strings.TOTTIME), "value", mElapsedTime);
                setFieldValue(WatchUi.loadResource(Rez.Strings.CADENCE), "value", mCurrentCadence);
                setFieldValue(WatchUi.loadResource(Rez.Strings.CALORIES), "value", mCalories);
                break;
            case  2:
                setFieldValue(WatchUi.loadResource(Rez.Strings.KPH), "value", mCurrentSpeed);
                setFieldValue(WatchUi.loadResource(Rez.Strings.KPH), "decimal", mCurrentSpeedDecimal);
                setFieldValue(WatchUi.loadResource(Rez.Strings.HR), "value", mHeartRate);
                setFieldValue(WatchUi.loadResource(Rez.Strings.DISTANCE), "value", mDistance);
                setFieldValue(WatchUi.loadResource(Rez.Strings.TOTTIME), "value", mElapsedTime);
                setFieldValue(WatchUi.loadResource(Rez.Strings.CALORIES), "value", mCalories);
                break;
            default:
                break;
        }

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

    hidden function initializeField(label as String) as Void {
        var labelView = View.findDrawableById(label) as Text;
        labelView.locY = labelView.locY - 16;
        labelView.setText(label);

        var valueView = View.findDrawableById(label + "_value");
        var valueViewText;
        if (valueView != null) {
            valueViewText = valueView as Text;
            valueViewText.locY = valueViewText.locY - 5;
            valueViewText.setText("N/A"); 
        }

        var decimalView = View.findDrawableById(label + "_decimal");
        var decimalViewText;
        if (decimalView != null) {
            decimalViewText = decimalView as Text;
            decimalViewText.locY = decimalViewText.locY - 5;
            decimalViewText.setText("0"); 
        }
    }

    hidden function setFieldValue(label as String, labelValueType as String, labelValue as String) as Void {
        var value = View.findDrawableById(label + "_" + labelValueType) as Text;
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            value.setColor(Graphics.COLOR_WHITE);
        } else {
            value.setColor(Graphics.COLOR_BLACK);
        }
        value.setText(labelValue);
    }

    hidden function readSettings() as Void {
        mActiveLayoutConfiguration = Application.Properties.getValue(WatchUi.loadResource(Rez.Strings.LAYOUT_SELECTOR_PROPERTY));
    }

    hidden function isSettingsChanged() as Boolean {
        var newLayoutConfiguration = Application.Properties.getValue(WatchUi.loadResource(Rez.Strings.LAYOUT_SELECTOR_PROPERTY));
        return newLayoutConfiguration != mActiveLayoutConfiguration;
    }
}
