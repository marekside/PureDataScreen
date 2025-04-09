import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class PureDataScreenView extends WatchUi.DataField {

    hidden var myFieldController = null;
    hidden var myCurrentLayout = 0;
    
    function initialize() {
        DataField.initialize();
        myFieldController = new FieldsController(self);
    }   

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
        switch (Application.Properties.getValue(WatchUi.loadResource(Rez.Strings.LAYOUT_SELECTOR_PROPERTY))) {
            case  1:
                View.setLayout(Rez.Layouts.WahooLayout16(dc));
                for (var i = 1; i <= 7; i++) {
                    myFieldController.initializeField("FIELD" + i, Application.Properties.getValue("field" + i));
                }
                break;
            case  2:
                View.setLayout(Rez.Layouts.WahooLayout14(dc));
                for (var i = 1; i <= 5; i++) {
                    myFieldController.initializeField("FIELD" + i, Application.Properties.getValue("field" + i));
                }
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
        myFieldController.compute(info);
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        handleLayoutChange(dc);
        (View.findDrawableById("Background") as Text).setColor(getBackgroundColor());
        myFieldController.redrawFieldValue();

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

    hidden function handleLayoutChange(dc as Dc) {
        View.findDrawableById("averageUp").setVisible(false);
        View.findDrawableById("averageDown").setVisible(false);
        
        var currentLayout = Application.Properties.getValue(WatchUi.loadResource(Rez.Strings.LAYOUT_SELECTOR_PROPERTY));
        if (currentLayout != myCurrentLayout) {
            myCurrentLayout = currentLayout;
            myFieldController.initialize(self);
            onLayout(dc);
        }

        if (myFieldController.isSourceChanged()) {
            myFieldController.initialize(self);
            onLayout(dc);
        }        
    }
}