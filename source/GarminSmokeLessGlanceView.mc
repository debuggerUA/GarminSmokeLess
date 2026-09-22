import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class GarminSmokeLessGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var count = SmokeLessTracker.getTodayCount();
        var remainingSeconds = SmokeLessTracker.getRemainingCooldownSeconds();

        var statusText = WatchUi.loadResource(Rez.Strings.GlanceReady) as String;
        if (remainingSeconds > 0) {
            statusText = Lang.format(WatchUi.loadResource(Rez.Strings.GlanceMinutesLeft) as String, [(remainingSeconds / 60) + 1]);
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var cigsText = Lang.format(WatchUi.loadResource(Rez.Strings.GlanceCigsCount) as String, [count]);
        dc.drawText(0, 5, Graphics.FONT_GLANCE, cigsText, Graphics.TEXT_JUSTIFY_LEFT);

        dc.setColor(remainingSeconds > 0 ? Graphics.COLOR_YELLOW : Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, 25, Graphics.FONT_GLANCE, statusText, Graphics.TEXT_JUSTIFY_LEFT);
    }
}
