---
name: build-project
description: Use to build current project
---

# To build from terminal:

```bash
./build.sh
```

This auto-detects the newest Connect IQ SDK under
`~/Library/Application Support/Garmin/ConnectIQ/Sdks`, and signs with
`./developer_key` (gitignored — place your Connect IQ signing key there).

Output goes to `bin/GarminSmokeLess.prg`, built for `fenix7` by default.

Overridable via `.build.local.env` (gitignored, see `.build.local.env.example`):
`SDK`, `KEY`, `DEVICE`, `OUT`.
