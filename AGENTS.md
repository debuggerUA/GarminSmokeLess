# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

GarminSmokeLess is a Garmin Connect IQ watch app (Monkey C) — a cigarette tracker with a cooldown timer. Target device is the `fenix7` (see `manifest.xml`); Connect IQ SDK v9.2.0, min API level 5.2.0.

## Build / run / test
- There is no automated test suite in this repo.
- `bin/` and `gen/` are build output directories (gitignored); do not hand-edit generated files under them.
- `manifest.xml` is a generated file (per its own header comment) — prefer editing it through the VS Code extension's "Monkey C: Edit ..." commands (products, permissions, languages, app attributes) rather than by hand, to keep it consistent with the SDK's expectations.

## Architecture

All cigarette-tracking logic (counts, cooldown, daily reset, persistence, complication publishing) lives in one place: `source/SmokeLessTracker.mc`, a stateless module used by every other surface. Don't duplicate this logic elsewhere — add new tracking behavior here and have the surfaces call into it.

The app has four independent entry points that all read/write through `SmokeLessTracker`:

- `GarminSmokeLessApp.mc` — `AppBase` subclass; wires up the full-screen view, the glance view, and the background service delegate, and registers the background temporal event.
- `GarminSmokeLessView.mc` + `GarminSmokeLessDelegate.mc` — the full-screen logging UI. The view runs a 1s repeating timer (started in `onShow`, stopped in `onHide`) to keep the cooldown countdown ticking; the delegate maps SELECT press and screen tap to logging a cigarette (with haptic feedback).
- `GarminSmokeLessGlanceView.mc` — compact glance/widget-list view showing today's count and cooldown status.
- `SmokeLessServiceDelegate.mc` — background service (`(:background)` annotated), invoked periodically via `Background.registerForTemporalEvent`, whose only job is to refresh the published complication while the app isn't running.

State is persisted via `Application.Storage` (`todayCount`, `lastLogDate`, `lastSmokedTime`) and configured via `Application.Properties` (`MaxDailyCigs`, `CooldownMinutes`, defined in `resources/settings/properties.xml`, editable by the user through Garmin Connect Mobile). `checkDailyReset()` compares a `YYYY-MM-DD` day key to detect and reset on day rollover; it's called defensively from `getTodayCount()`, `onStart()`, and the background service.

The tracker also publishes a Connect IQ **complication** (`Toybox.Complications`) so other watch faces / Face It can display the count and cooldown. The complication `id` in `SmokeLessTracker.COMPLICATION_ID` must stay in sync with the `id` in `resources/complications/complications.xml` — it's referenced externally by other watch faces, so treat it as a stable, non-renumberable identifier. Complication and background APIs are not supported on all devices/API levels; calls to `Complications.updateComplication` and `Background.registerForTemporalEvent` are wrapped in `try/catch` and failures are intentionally swallowed.

Build-target annotations (`(:glance)`, `(:background)`) mark code that's only compiled in for devices/contexts that support that feature — keep new glance- or background-only code annotated the same way.
