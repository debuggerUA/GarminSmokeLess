import Toybox.Lang;
import Toybox.WatchUi;

//! Handles selection on a preset-value submenu (pushed by
//! SmokeLessSettingsMenuDelegate) and confirms the change before persisting
//! it, per Garmin's Confirmations UX guideline:
//! https://developer.garmin.com/connect-iq/user-experience-guidelines/confirmations/
class SmokeLessValueMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var _kind as Symbol;
    private var _targetItem as WatchUi.MenuItem;

    function initialize(kind as Symbol, targetItem as WatchUi.MenuItem) {
        Menu2InputDelegate.initialize();
        _kind = kind;
        _targetItem = targetItem;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var value = item.getId() as Number;
        var titleId = (_kind == :cooldown) ? Rez.Strings.CooldownTitle : Rez.Strings.MaxDailyTitle;
        var label = WatchUi.loadResource(titleId) as String;
        var valueText = (_kind == :cooldown)
            ? Lang.format("$1$ $2$", [value, WatchUi.loadResource(Rez.Strings.MinutesUnit)])
            : value.toString();

        var message = Lang.format("$1$: $2$?", [label, valueText]);

        WatchUi.pushView(
            new WatchUi.Confirmation(message),
            new SmokeLessValueConfirmDelegate(_kind, value, _targetItem),
            WatchUi.SLIDE_IMMEDIATE
        );
    }
}

//! Persists the chosen value once the user confirms it, and updates the
//! settings menu item's sub-label in place so it reflects the new value
//! without needing to rebuild the whole menu.
class SmokeLessValueConfirmDelegate extends WatchUi.ConfirmationDelegate {
    private var _kind as Symbol;
    private var _value as Number;
    private var _targetItem as WatchUi.MenuItem;

    function initialize(kind as Symbol, value as Number, targetItem as WatchUi.MenuItem) {
        ConfirmationDelegate.initialize();
        _kind = kind;
        _value = value;
        _targetItem = targetItem;
    }

    function onResponse(response as WatchUi.Confirm) as Boolean {
        if (response == WatchUi.CONFIRM_YES) {
            if (_kind == :cooldown) {
                SmokeLessTracker.setCooldownMinutes(_value);
                _targetItem.setSubLabel(Lang.format("$1$ $2$", [_value, WatchUi.loadResource(Rez.Strings.MinutesUnit)]));
            } else {
                SmokeLessTracker.setMaxDaily(_value);
                _targetItem.setSubLabel(_value.toString());
            }

            SmokeLessTracker.publishComplication();
            WatchUi.requestUpdate();

            // The Confirmation view pops itself; also pop the value list so
            // the user lands back on the settings menu with the new value.
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }

        return true;
    }
}
