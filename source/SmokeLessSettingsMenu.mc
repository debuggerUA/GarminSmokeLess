import Toybox.Lang;
import Toybox.WatchUi;

//! On-watch settings menu (Menu2) letting the user adjust MaxDailyCigs and
//! CooldownMinutes directly on the device, without needing Garmin Connect
//! Mobile. Reachable from GarminSmokeLessDelegate.onMenu() (hold the MENU
//! button). See Garmin's Menus UX guideline:
//! https://developer.garmin.com/connect-iq/user-experience-guidelines/menus/
//!
//! Values chosen here are persisted via SmokeLessTracker.setMaxDaily() /
//! setCooldownMinutes(), which write through Application.Properties so
//! Garmin Connect Mobile's settings screen stays in sync (see
//! resources/settings/settings.xml).
class SmokeLessSettingsMenu extends WatchUi.Menu2 {
    var maxDailyItem as WatchUi.MenuItem;
    var cooldownItem as WatchUi.MenuItem;

    function initialize() {
        Menu2.initialize({ :title => WatchUi.loadResource(Rez.Strings.SettingsTitle) });

        maxDailyItem = new WatchUi.MenuItem(
            WatchUi.loadResource(Rez.Strings.MaxDailyTitle),
            SmokeLessTracker.getMaxDaily().toString(),
            :maxDaily,
            {}
        );
        addItem(maxDailyItem);

        cooldownItem = new WatchUi.MenuItem(
            WatchUi.loadResource(Rez.Strings.CooldownTitle),
            Lang.format("$1$ $2$", [SmokeLessTracker.getCooldownMinutes(), WatchUi.loadResource(Rez.Strings.MinutesUnit)]),
            :cooldown,
            {}
        );
        addItem(cooldownItem);
    }
}
