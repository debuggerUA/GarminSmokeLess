import Toybox.Background;
import Toybox.Lang;
import Toybox.System;

//! Runs periodically while the app is closed so the published complication
//! (count + cooldown) stays reasonably fresh on other watch faces / Face It.
(:background)
class SmokeLessServiceDelegate extends System.ServiceDelegate {

    function initialize() {
        ServiceDelegate.initialize();
    }

    function onTemporalEvent() as Void {
        SmokeLessTracker.checkDailyReset();
        SmokeLessTracker.publishComplication();
        // Re-arm the schedule: a temporal event is one-shot until it's
        // re-registered here, otherwise it silently stops after this firing.
        SmokeLessTracker.scheduleBackgroundRefresh();
        Background.exit(null);
    }
}
