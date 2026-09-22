---
name: test-project
description: Use to run the unit test suite
---

# To run the unit test suite:

```bash
./test.sh
```

Builds with `monkeyc -t` (compiling in `(:test)`-annotated functions from
`source/test/SmokeLessTrackerTest.mc`), launches the simulator if needed, and runs
`monkeydo -t` to execute them, printing PASS/ERROR per test plus a summary.

Overridable via `.build.local.env` (gitignored, see `.build.local.env.example`):
`SDK`, `KEY`, `DEVICE`, `TEST_OUT`.
