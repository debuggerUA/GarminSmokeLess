---
name: run-project
description: Use to run current project in the emulator
---

# To run pre-built project:

`monkeydo` needs the simulator to be up and listening before it connects, so
launch `connectiq` first and give it a few seconds to start:

```bash
SDK=$(ls -d ~/Library/"Application Support"/Garmin/ConnectIQ/Sdks/*/ | sort | tail -1); SDK="${SDK%/}"

# Launch the simulator if it isn't already running, and wait for it to be ready.
pgrep -f "$SDK/bin/connectiq" > /dev/null || nohup "$SDK/bin/connectiq" > /tmp/connectiq.log 2>&1 &
sleep 5

"$SDK/bin/monkeydo" bin/GarminSmokeLess.prg fenix7
```
