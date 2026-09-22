import Toybox.Test;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Application.Storage;
import Toybox.Application.Properties;

function resetTrackerStorage() as Void {
    Storage.deleteValue("todayCount");
    Storage.deleteValue("lastLogDate");
    Storage.deleteValue("lastSmokedTime");
}

// --- Data storage ---

(:test)
function testGetLastSmokedTimeDefaultsToZero(logger as Test.Logger) as Boolean {
    resetTrackerStorage();
    Test.assertEqualMessage(SmokeLessTracker.getLastSmokedTime(), 0, "lastSmokedTime should default to 0 when unset");
    return true;
}

(:test)
function testGetTodayCountDefaultsToZero(logger as Test.Logger) as Boolean {
    resetTrackerStorage();
    Test.assertEqualMessage(SmokeLessTracker.getTodayCount(), 0, "getTodayCount should default to 0 with no prior state");
    return true;
}

(:test)
function testLogCigaretteIncrementsAndPersists(logger as Test.Logger) as Boolean {
    resetTrackerStorage();
    Storage.setValue("lastLogDate", SmokeLessTracker.todayKey());
    Storage.setValue("todayCount", 2);
    SmokeLessTracker.logCigarette();
    Test.assertEqualMessage(Storage.getValue("todayCount"), 3, "logCigarette should increment todayCount by 1");
    Test.assertMessage(Storage.getValue("lastSmokedTime") != null, "logCigarette should persist lastSmokedTime");
    return true;
}

// --- Timers (day-rollover + cooldown math) ---

(:test)
function testCheckDailyResetOnDateMismatch(logger as Test.Logger) as Boolean {
    resetTrackerStorage();
    Storage.setValue("lastLogDate", "2000-01-01");
    Storage.setValue("todayCount", 7);
    SmokeLessTracker.checkDailyReset();
    Test.assertEqualMessage(Storage.getValue("todayCount"), 0, "checkDailyReset should zero todayCount on day rollover");
    Test.assertEqualMessage(Storage.getValue("lastLogDate"), SmokeLessTracker.todayKey(), "checkDailyReset should update lastLogDate to today");
    return true;
}

(:test)
function testCheckDailyResetNoOpWhenSameDay(logger as Test.Logger) as Boolean {
    resetTrackerStorage();
    Storage.setValue("lastLogDate", SmokeLessTracker.todayKey());
    Storage.setValue("todayCount", 4);
    SmokeLessTracker.checkDailyReset();
    Test.assertEqualMessage(Storage.getValue("todayCount"), 4, "checkDailyReset should not touch todayCount when lastLogDate matches today");
    return true;
}

(:test)
function testCheckDailyResetWhenLastLogDateNull(logger as Test.Logger) as Boolean {
    resetTrackerStorage();
    Storage.setValue("todayCount", 9);
    SmokeLessTracker.checkDailyReset();
    Test.assertEqualMessage(Storage.getValue("todayCount"), 0, "checkDailyReset should reset when lastLogDate was never set");
    return true;
}

(:test)
function testTodayKeyFormat(logger as Test.Logger) as Boolean {
    var key = SmokeLessTracker.todayKey();
    Test.assertEqualMessage(key.length(), 10, "todayKey should be 10 characters (YYYY-MM-DD)");
    Test.assertEqualMessage(key.substring(4, 5), "-", "todayKey should have a dash at index 4");
    Test.assertEqualMessage(key.substring(7, 8), "-", "todayKey should have a dash at index 7");
    return true;
}

(:test)
function testIsReadyWhenNeverSmoked(logger as Test.Logger) as Boolean {
    resetTrackerStorage();
    Test.assertMessage(SmokeLessTracker.isReady(), "isReady should be true when never smoked");
    Test.assertEqualMessage(SmokeLessTracker.getRemainingCooldownSeconds(), 0, "remaining cooldown should be 0 when never smoked");
    return true;
}

(:test)
function testIsReadyFalseDuringCooldown(logger as Test.Logger) as Boolean {
    resetTrackerStorage();
    Properties.setValue("CooldownMinutes", 90);
    Storage.setValue("lastSmokedTime", Time.now().value());
    Test.assertMessage(!SmokeLessTracker.isReady(), "isReady should be false immediately after smoking");
    Test.assertMessage(SmokeLessTracker.getRemainingCooldownSeconds() > 0, "remaining cooldown should be positive immediately after smoking");
    return true;
}

(:test)
function testIsReadyTrueAfterCooldownElapsed(logger as Test.Logger) as Boolean {
    resetTrackerStorage();
    Properties.setValue("CooldownMinutes", 1);
    Storage.setValue("lastSmokedTime", Time.now().value() - 120);
    Test.assertMessage(SmokeLessTracker.isReady(), "isReady should be true once cooldown has elapsed");
    Test.assertMessage(SmokeLessTracker.getRemainingCooldownSeconds() <= 0, "remaining cooldown should be <= 0 once elapsed");
    return true;
}

(:test)
function testRemainingCooldownSecondsMath(logger as Test.Logger) as Boolean {
    resetTrackerStorage();
    Properties.setValue("CooldownMinutes", 10);
    Storage.setValue("lastSmokedTime", Time.now().value() - 100);
    var remaining = SmokeLessTracker.getRemainingCooldownSeconds();
    Test.assertMessage(remaining >= 498 && remaining <= 502, "remaining cooldown should be ~500s (600 - 100)");
    return true;
}

// getMaxDaily()/getCooldownMinutes() have no dedicated tests: Properties has
// no way to unset a key at runtime (no deleteValue/clearValue, and setValue
// rejects null), so a test can only assert Properties round-trips a value,
// not exercise any app logic. getCooldownMinutes() is still covered
// indirectly above via getRemainingCooldownSeconds()/isReady(), which
// consume it as part of real cooldown-math logic.
