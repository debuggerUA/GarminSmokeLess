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

    // Handles the physical MENU gesture (hold UP on fenix7) - opens the
    // on-watch settings menu, so it doesn't conflict with logging a
    // cigarette via SELECT/tap.
    function onMenu() as Boolean {
        var menu = new SmokeLessSettingsMenu();
        WatchUi.pushView(menu, new SmokeLessSettingsMenuDelegate(menu), WatchUi.SLIDE_UP);
        return true;
    }

    private function logCigarette() as Void {
        _view.logCigarette();

        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(50, 200)]); // Haptic feedback
        }
    }
}
