import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class MyFirstDataScreenView extends WatchUi.DataField {

    hidden var mCurrentSpeed as String;
    hidden var mHeartRate as String;
    hidden var mPower3s as String;
    hidden var mDistance as String;
    
    function initialize() {
        DataField.initialize();
        mCurrentSpeed = "n/a";
        mHeartRate = "n/a";
        mPower3s = "n/a";
        mDistance = "n/a";
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
        View.setLayout(Rez.Layouts.WahooLayout(dc));
        initializeField(WatchUi.loadResource(Rez.Strings.KPH));
        initializeField(WatchUi.loadResource(Rez.Strings.HR));
        
        // var labelView = View.findDrawableById("KPH") as Text;
        // labelView.locY = labelView.locY - 16;
        // var valueView = View.findDrawableById("KPH_value") as Text;
        // valueView.locY = valueView.locY + 7;
    
        // (View.findDrawableById("KPH") as Text).setText("KPH");
    }
    
    hidden function initializeField(label as String) as Void {
        var labelView = View.findDrawableById(label) as Text;
        labelView.locY = labelView.locY - 16;
        var valueView = View.findDrawableById(label + "_value") as Text;
        valueView.locY = valueView.locY - 5;
    
        (View.findDrawableById(label) as Text).setText(label);
        (View.findDrawableById(label + "_value") as Text).setText("N/A");
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
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // Set the background color
        (View.findDrawableById("Background") as Text).setColor(getBackgroundColor());

        // Set the foreground color and value
        var value = View.findDrawableById("KPH_value") as Text;
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            value.setColor(Graphics.COLOR_WHITE);
        } else {
            value.setColor(Graphics.COLOR_BLACK);
        }
        value.setText(mCurrentSpeed);
        
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
