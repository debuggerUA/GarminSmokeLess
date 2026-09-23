import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Application.Properties;
import Toybox.Complications;

//! Shared cigarette-tracking logic used by the logging view, the glance,
//! the background service, and the published complication. Keeping all of
//! this in one place avoids re-implementing the same rules in each surface.
module SmokeLessTracker {

    // Must stay stable across releases; referenced from resources/complications/complications.xml
    const COMPLICATION_ID = 0;

    const DEFAULT_MAX_DAILY = 10;
    const DEFAULT_COOLDOWN_MINUTES = 90;

    //! Max cigarettes/day configured by the user, with a safe fallback.
    (:background, :glance)
    function getMaxDaily() as Number {
        var value = Properties.getValue("MaxDailyCigs");
        return (value == null) ? DEFAULT_MAX_DAILY : value as Number;
    }

    //! Cooldown length in minutes configured by the user, with a safe fallback.
    (:background, :glance)
    function getCooldownMinutes() as Number {
        var value = Properties.getValue("CooldownMinutes");
        return (value == null) ? DEFAULT_COOLDOWN_MINUTES : value as Number;
    }

    //! Persists a new daily limit. Writes through Application.Properties so the
    //! value stays in sync with what Garmin Connect Mobile shows (see
    //! resources/settings/settings.xml), regardless of whether it was changed
    //! there or from the on-watch settings menu.
    function setMaxDaily(value as Number) as Void {
        Properties.setValue("MaxDailyCigs", value);
    }

    //! Persists a new cooldown length, in minutes. See setMaxDaily() for why
    //! this goes through Application.Properties.
    function setCooldownMinutes(value as Number) as Void {
        Properties.setValue("CooldownMinutes", value);
    }

    //! Stable "YYYY-MM-DD" key for the current local day, used to detect day rollover.
    (:background, :glance)
    function todayKey() as String {
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        return Lang.format("$1$-$2$-$3$", [today.year, today.month.format("%02d"), today.day.format("%02d")]);
    }

    //! Resets the daily counter when the stored day no longer matches today.
    (:background, :glance)
    function checkDailyReset() as Void {
        var today = todayKey();
        var lastDay = Storage.getValue("lastLogDate");

        if (lastDay == null || !(lastDay.equals(today))) {
            Storage.setValue("todayCount", 0);
            Storage.setValue("lastLogDate", today);
        }
    }

    //! Number of cigarettes logged so far today.
    (:background, :glance)
    function getTodayCount() as Number {
        checkDailyReset();
        var count = Storage.getValue("todayCount");
        return (count == null) ? 0 : count as Number;
    }

    //! Epoch seconds of the last logged cigarette, or 0 if none has been logged.
    (:background, :glance)
    function getLastSmokedTime() as Number {
        var lastTime = Storage.getValue("lastSmokedTime");
        return (lastTime == null) ? 0 : lastTime as Number;
    }

    //! Seconds remaining in the cooldown window. <= 0 means the cooldown is over.
    (:background, :glance)
    function getRemainingCooldownSeconds() as Number {
        var lastTime = getLastSmokedTime();
        if (lastTime == 0) {
            return 0;
        }

        var elapsed = Time.now().value() - lastTime;
        var cooldownSeconds = getCooldownMinutes() * 60;
        return cooldownSeconds - elapsed;
    }

    //! True when there has been no cigarette yet today or the cooldown has elapsed.
    (:background, :glance)
    function isReady() as Boolean {
        return getLastSmokedTime() == 0 || getRemainingCooldownSeconds() <= 0;
    }

    //! Logs a cigarette now. Always allowed - the cooldown is a reminder, not a lock.
    (:background, :glance)
    function logCigarette() as Void {
        var count = getTodayCount();
        Storage.setValue("todayCount", count + 1);
        Storage.setValue("lastSmokedTime", Time.now().value());
        publishComplication();
    }

    //! Publishes the current count/cooldown state as a complication so other
    //! Connect IQ watch faces (and Face It) can display it. Not every device
    //! supports complications, so publishing failures are swallowed.
    (:background, :glance)
    function publishComplication() as Void {
        var count = getTodayCount();
        var remaining = getRemainingCooldownSeconds();
        var status = (remaining > 0) ? Lang.format("$1$m", [(remaining + 59) / 60]) : "RDY";

        try {
            Complications.updateComplication(COMPLICATION_ID, {
                :value => Lang.format("$1$ $2$", [count, status]),
                :shortLabel => Application.loadResource(Rez.Strings.ComplicationShortLabel) as String,
            });
        } catch (ex) {
            // Complications are unsupported on this device/API level; ignore.
        }
    }
}
