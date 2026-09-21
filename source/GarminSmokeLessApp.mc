import Toybox.Application;
import Toybox.Background;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

class GarminSmokeLessApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        SmokeLessTracker.checkDailyReset();
        SmokeLessTracker.publishComplication();

        try {
            Background.registerForTemporalEvent(new Time.Duration(5 * 60));
        } catch (ex) {
            // Background service is unsupported on this device; ignore.
        }
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // App launch (full screen logging view)
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new GarminSmokeLessView();
        var delegate = new GarminSmokeLessDelegate(view);
        return [ view, delegate ];
    }

    // Glance view (for the widget list)
    (:glance)
    function getGlanceView() as [Views] or [Views, InputDelegates] {
        return [ new GarminSmokeLessGlanceView() ];
    }

    // Background service, used to keep the published complication fresh
    // while the app itself is not running.
    (:background)
    function getServiceDelegate() as [ServiceDelegate] {
        return [ new SmokeLessServiceDelegate() ];
    }

    // Called automatically by the system whenever settings are changed via Garmin Connect Mobile
    function onSettingsChanged() as Void {
        SmokeLessTracker.publishComplication();
        WatchUi.requestUpdate(); // Trigger a screen redraw
    }

}

function getApp() as GarminSmokeLessApp {
    return Application.getApp() as GarminSmokeLessApp;
}
