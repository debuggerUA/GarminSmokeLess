import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

//! Main logging screen: shows today's count vs the daily limit and the
//! cooldown timer, and lets the user log a cigarette (tap / SELECT).
class GarminSmokeLessView extends WatchUi.View {

    private var _timer as Timer.Timer?;

    function initialize() {
        View.initialize();
    }

    function onShow() as Void {
        // Refresh once a second so the cooldown timer ticks visibly.
        _timer = new Timer.Timer();
        _timer.start(method(:requestUpdate), 1000, true);
    }

    function onHide() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    function requestUpdate() as Void {
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var maxDaily = SmokeLessTracker.getMaxDaily();
        var count = SmokeLessTracker.getTodayCount();
        var remainingSeconds = SmokeLessTracker.getRemainingCooldownSeconds();

        // Today's count
        dc.setColor(count >= maxDaily ? Graphics.COLOR_RED : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, 40, Graphics.FONT_MEDIUM, "Today: " + count + " / " + maxDaily, Graphics.TEXT_JUSTIFY_CENTER);

        // Cooldown status
        if (remainingSeconds <= 0) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - 10, Graphics.FONT_LARGE, "READY", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            var mins = remainingSeconds / 60;
            var secs = remainingSeconds % 60;
            var timeStr = Lang.format("$1$:$2$", [mins.format("%02d"), secs.format("%02d")]);

            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - 20, Graphics.FONT_MEDIUM, "Cooldown:", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 + 10, Graphics.FONT_NUMBER_MEDIUM, timeStr, Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Instruction
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - 45, Graphics.FONT_XTINY, "Tap or press SELECT to log", Graphics.TEXT_JUSTIFY_CENTER);
    }

    //! Logs a cigarette and immediately redraws.
    function logCigarette() as Void {
        SmokeLessTracker.logCigarette();
        WatchUi.requestUpdate();
    }

}
