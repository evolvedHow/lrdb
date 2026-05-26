#!/usr/bin/env bash
# Sync data files from the FDP shared data platform into lrdb/public/assets/.
#
# Usage:
#   ./scripts/sync_data.sh
#   FDP_WORKSPACE=my_shapes ./scripts/sync_data.sh
#   ./scripts/sync_data.sh --dry-run

set -e
cd "$(dirname "$0")/.."

DEST="$(pwd)/public/assets"
FDP_ROOT="${FDP_ROOT:-$(realpath ../fdp)}"

mkdir -p "$DEST/update_helper"
echo "FDP root  : $FDP_ROOT"
echo "Dest      : $DEST"
echo ""

FDP_ROOT="$FDP_ROOT" python -m fdp.cli sync-app lrdb --dest "$DEST" "$@"
