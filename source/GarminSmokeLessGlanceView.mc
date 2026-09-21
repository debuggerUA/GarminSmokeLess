import Toybox.Graphics;
import Toybox.WatchUi;

(:glance)
class GarminSmokeLessGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var count = SmokeLessTracker.getTodayCount();
        var remainingSeconds = SmokeLessTracker.getRemainingCooldownSeconds();

        var statusText = "Ready";
        if (remainingSeconds > 0) {
            statusText = ((remainingSeconds / 60) + 1) + "m left";
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, 5, Graphics.FONT_GLANCE, "Cigs: " + count, Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(remainingSeconds > 0 ? Graphics.COLOR_YELLOW : Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, 25, Graphics.FONT_GLANCE_NUMBER, statusText, Graphics.TEXT_JUSTIFY_LEFT);
    }
}
