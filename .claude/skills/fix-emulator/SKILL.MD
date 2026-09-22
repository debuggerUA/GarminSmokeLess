---
name: fix-simulator
description: Use when the Connect IQ simulator is stuck (blank/white screen, unresponsive, won't close, or monkeydo hangs with no output) — kills the wedged simulator and relaunches it cleanly
---

# Unstick a wedged Connect IQ simulator

## Symptom

The simulator window shows the device skin but a white/blank screen, doesn't
respond to input, and can't be closed via the red close button. Or: running
`monkeydo` produces no output at all and never returns (it should return
within a few seconds — either a clean launch or a crash trace).

## Cause

This almost always means the simulator process is alive but its command
listener got wedged — usually because something (a prior `monkeydo` call, a
health check, etc.) connected to it before it had finished starting up. The
simulator's listener is single-threaded, so one bad/early connection blocks
every deploy after it, including ones from a freshly-run `monkeydo`.

## Fix

Kill every simulator-related process, relaunch clean, and — critically —
wait for the simulator to be fully ready *before* calling `monkeydo`. Don't
just wait for its port to open; open-but-not-ready is exactly what caused the
wedge in the first place.

```bash
SDK=$(ls -d ~/Library/"Application Support"/Garmin/ConnectIQ/Sdks/*/ | sort | tail -1); SDK="${SDK%/}"

# 1. Kill any existing (possibly wedged) simulator and its transport shell.
pkill -f "ConnectIQ.app/Contents/MacOS/simulator" 2>/dev/null
pkill -f "$SDK/bin/shell" 2>/dev/null
sleep 1

# 2. Relaunch the simulator fresh.
open "$SDK/bin/ConnectIQ.app"

# 3. Wait for it to actually be ready — not just "port open."
#    A fixed buffer is simpler and more reliable than polling the port,
#    since an open port doesn't mean the simulator has finished init.
sleep 10

# 4. Now deploy.
"$SDK/bin/monkeydo" bin/GarminSmokeLess.prg fenix7
