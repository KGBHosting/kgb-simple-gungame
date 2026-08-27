#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AMXX_VERSION="${AMXX_VERSION:-1.8.2}"
SOURCE="$ROOT_DIR/src/kgb_simple_gungame.sma"
INCLUDE="$ROOT_DIR/.ci/amxx/$AMXX_VERSION/addons/amxmodx/scripting/include/amxmodx.inc"

grep -F 'public client_disconnect(id)' "$SOURCE" >/dev/null
grep -F 'public client_disconnected(id, bool:drop, message[], maxlen)' "$SOURCE" >/dev/null
test "$(grep -Fc 'cleanupDisconnectedClient(id)' "$SOURCE")" -eq 3
grep -A3 -F 'stock cleanupDisconnectedClient(id)' "$SOURCE" | grep -F 'remove_task(TASK_EQUIP_BASE + id)' >/dev/null
grep -A4 -F 'stock cleanupDisconnectedClient(id)' "$SOURCE" | grep -F 'resetPlayer(id)' >/dev/null

test -f "$INCLUDE"
grep -F 'forward client_disconnect(id);' "$INCLUDE" >/dev/null
case "$AMXX_VERSION" in
    1.8|1.8.2)
        ! grep -F 'forward client_disconnected(' "$INCLUDE" >/dev/null
        ;;
    1.9|1.10)
        grep -F 'forward client_disconnected(id, bool:drop, message[], maxlen);' "$INCLUDE" >/dev/null
        ;;
    *)
        printf 'Unsupported AMXX_VERSION: %s\n' "$AMXX_VERSION" >&2
        exit 1
        ;;
esac
