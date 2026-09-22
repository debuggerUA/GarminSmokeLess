import Toybox.Lang;
import Toybox.WatchUi;

//! Handles selection on the root settings menu (SmokeLessSettingsMenu),
//! drilling into a preset-value submenu for whichever setting was tapped.
class SmokeLessSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var _menu as SmokeLessSettingsMenu;

    function initialize(menu as SmokeLessSettingsMenu) {
        Menu2InputDelegate.initialize();
        _menu = menu;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();

        if (id == :maxDaily) {
            pushValueMenu(
                :maxDaily,
                WatchUi.loadResource(Rez.Strings.MaxDailyTitle) as String,
                [1, 5, 10, 15, 20, 25, 30, 40, 50],
                SmokeLessTracker.getMaxDaily(),
                _menu.maxDailyItem
            );
        } else if (id == :cooldown) {
            pushValueMenu(
                :cooldown,
                WatchUi.loadResource(Rez.Strings.CooldownTitle) as String,
                [15, 30, 45, 60, 90, 120, 180, 240],
                SmokeLessTracker.getCooldownMinutes(),
                _menu.cooldownItem
            );
        }
    }

    private function pushValueMenu(
        kind as Symbol,
        title as String,
        values as Array<Number>,
        current as Number,
        targetItem as WatchUi.MenuItem
    ) as Void {
        var valueMenu = new WatchUi.Menu2({ :title => title });
        var currentLabel = WatchUi.loadResource(Rez.Strings.CurrentValueLabel) as String;

        for (var i = 0; i < values.size(); i += 1) {
            var value = values[i];
            var label = (kind == :cooldown)
                ? Lang.format("$1$ $2$", [value, WatchUi.loadResource(Rez.Strings.MinutesUnit)])
                : value.toString();

            valueMenu.addItem(new WatchUi.MenuItem(
                label,
                (value == current) ? currentLabel : null,
                value,
                {}
            ));
        }

        WatchUi.pushView(valueMenu, new SmokeLessValueMenuDelegate(kind, targetItem), WatchUi.SLIDE_LEFT);
    }
}
