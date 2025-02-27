import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class PureDataScreenView extends WatchUi.DataField {

    hidden var mCurrentSpeed as String;
    hidden var mCurrentSpeedAvg as String;
    hidden var mHeartRate as String;
    hidden var mPower3s as String;
    hidden var mDistance as String;
    hidden var mElapsedTime as String;
    hidden var mCurrentCadence as String;
    hidden var mCalories as String;
    
    
    function initialize() {
        DataField.initialize();
        mCurrentSpeed = "n/a";
        mHeartRate = "n/a";
        mPower3s = "n/a";
        mDistance = "n/a";
        mElapsedTime = "n/a";
        mCurrentCadence = "n/a";
        mCalories = "n/a";
        mCurrentSpeedAvg = "n/a";
    }   

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
        View.setLayout(Rez.Layouts.WahooLayout(dc));
        initializeField(WatchUi.loadResource(Rez.Strings.KPH));
        //initializeField(WatchUi.loadResource(Rez.Strings.KPHAVG));
        initializeField(WatchUi.loadResource(Rez.Strings.HR));
        initializeField(WatchUi.loadResource(Rez.Strings.PWR));
        initializeField(WatchUi.loadResource(Rez.Strings.DISTANCE));
        initializeField(WatchUi.loadResource(Rez.Strings.TOTTIME));
        initializeField(WatchUi.loadResource(Rez.Strings.CADENCE));
        initializeField(WatchUi.loadResource(Rez.Strings.CALORIES));
        
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
                var roundedSpeedKmh = Math.round(speedKmh).toNumber(); // Round to the nearest integer
                mCurrentSpeed = roundedSpeedKmh.toString();
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

        if(info has :averageSpeed ){
            if(info.averageSpeed  != null){
                var speedKmh = info.averageSpeed * 3.6; // Convert m/s to km/h
                var roundedSpeedKmh = Math.round(speedKmh).toNumber(); // Round to the nearest integer
                mCurrentSpeedAvg = roundedSpeedKmh.toString();
            } else {
                mCurrentSpeedAvg = "n/a";
            }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // Set the background color
        (View.findDrawableById("Background") as Text).setColor(getBackgroundColor());

        setFieldValue(WatchUi.loadResource(Rez.Strings.KPH), mCurrentSpeed);
        //setFieldValue(WatchUi.loadResource(Rez.Strings.KPHAVG), mCurrentSpeedAvg);
        setFieldValue(WatchUi.loadResource(Rez.Strings.HR), mHeartRate);
        setFieldValue(WatchUi.loadResource(Rez.Strings.PWR), mPower3s);
        setFieldValue(WatchUi.loadResource(Rez.Strings.DISTANCE), mDistance);
        setFieldValue(WatchUi.loadResource(Rez.Strings.TOTTIME), mElapsedTime);
        setFieldValue(WatchUi.loadResource(Rez.Strings.CADENCE), mCurrentCadence);
        setFieldValue(WatchUi.loadResource(Rez.Strings.CALORIES), mCalories);

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
    }

    hidden function setFieldValue(label as String, labelValue as String) as Void {
        // Set the foreground color and value
        var value = View.findDrawableById(label + "_value") as Text;
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            value.setColor(Graphics.COLOR_WHITE);
        } else {
            value.setColor(Graphics.COLOR_BLACK);
        }
        value.setText(labelValue);
    }
}
