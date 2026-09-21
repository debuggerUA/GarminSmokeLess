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
        Background.exit(null);
    }
}
