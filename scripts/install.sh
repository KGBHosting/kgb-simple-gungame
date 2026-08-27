#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CSTRIKE_DIR="${1:?Usage: scripts/install.sh /path/to/cstrike}"
PLUGIN_FILE="kgb_simple_gungame.amxx"

test -s "$ROOT_DIR/compiled/$PLUGIN_FILE"
mkdir -p \
    "$CSTRIKE_DIR/addons/amxmodx/plugins" \
    "$CSTRIKE_DIR/addons/amxmodx/configs" \
    "$CSTRIKE_DIR/addons/amxmodx/licenses"

cp "$ROOT_DIR/compiled/$PLUGIN_FILE" "$CSTRIKE_DIR/addons/amxmodx/plugins/$PLUGIN_FILE"
cp "$ROOT_DIR/LICENSE" "$CSTRIKE_DIR/addons/amxmodx/licenses/kgb_simple_gungame-LICENSE.txt"

config="$CSTRIKE_DIR/addons/amxmodx/configs/kgb_simple_gungame.cfg"
if ! test -e "$config"; then
    cp "$ROOT_DIR/configs/kgb_simple_gungame.cfg.example" "$config"
fi

plugins_ini="$CSTRIKE_DIR/addons/amxmodx/configs/plugins.ini"
touch "$plugins_ini"
grep -Eq "^[[:space:]]*$PLUGIN_FILE([[:space:]]|$)" "$plugins_ini" \
    || printf '%s\n' "$PLUGIN_FILE" >> "$plugins_ini"
