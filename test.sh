#!/usr/bin/env bash
# Builds and runs the GarminSmokeLess unit test suite (Toybox.Test).
#
# Machine-specific paths (SDK location, signing key) can be overridden via
# .build.local.env (gitignored) — see .build.local.env.example.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if [ -f .build.local.env ]; then
    # shellcheck source=/dev/null
    source .build.local.env
fi

DEVICE="${DEVICE:-fenix7}"
TEST_OUT="${TEST_OUT:-bin/GarminSmokeLessTest.prg}"

if [ -z "${SDK:-}" ]; then
    SDK_ROOT="$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks"
    SDK=$(find "$SDK_ROOT" -maxdepth 1 -type d -name 'connectiq-sdk-*' 2>/dev/null | sort -V | tail -n1 || true)
fi

if [ -z "${SDK:-}" ] || [ ! -x "$SDK/bin/monkeyc" ]; then
    echo "error: could not find Connect IQ SDK (monkeyc)." >&2
    echo "Set SDK=/path/to/connectiq-sdk in .build.local.env (see .build.local.env.example)." >&2
    exit 1
fi

KEY="${KEY:-developer_key}"

if [ ! -f "$KEY" ]; then
    echo "error: developer signing key not found at $KEY" >&2
    echo "Place your Connect IQ developer_key at ./developer_key (gitignored)," >&2
    echo "or set KEY=/path/to/developer_key in .build.local.env." >&2
    exit 1
fi

mkdir -p "$(dirname "$TEST_OUT")"

echo "Using SDK: $SDK"
"$SDK/bin/monkeyc" -t -f monkey.jungle -o "$TEST_OUT" -y "$KEY" -d "$DEVICE"

pgrep -f "$SDK/bin/connectiq" > /dev/null || nohup "$SDK/bin/connectiq" > /tmp/connectiq.log 2>&1 &
sleep 10

"$SDK/bin/monkeydo" "$TEST_OUT" "$DEVICE" -t
