import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class GarminSmokeLessDelegate extends WatchUi.BehaviorDelegate {
    private var _view as GarminSmokeLessView;

    function initialize(view as GarminSmokeLessView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // Handles physical SELECT button
    function onSelect() as Boolean {
        logCigarette();
        return true;
    }

    // Handles a screen tap
    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        logCigarette();
        return true;
    }

    private function logCigarette() as Void {
        _view.logCigarette();

        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(50, 200)]); // Haptic feedback
        }
    }
}
