#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$(mktemp -d)"
trap 'rm -rf "$target"' EXIT

printf '%s\n' 'customer_owned_setting 1' > "$target/customer.cfg"
"$ROOT_DIR/scripts/install.sh" "$target"
printf '%s\n' 'kgb_gg_display_name "Customer GunGame"' > "$target/addons/amxmodx/configs/kgb_simple_gungame.cfg"
"$ROOT_DIR/scripts/install.sh" "$target"

test -s "$target/addons/amxmodx/plugins/kgb_simple_gungame.amxx"
test -s "$target/addons/amxmodx/licenses/kgb_simple_gungame-LICENSE.txt"
grep -Fx 'kgb_gg_display_name "Customer GunGame"' "$target/addons/amxmodx/configs/kgb_simple_gungame.cfg"
test "$(grep -Ec '^[[:space:]]*kgb_simple_gungame\.amxx([[:space:]]|$)' "$target/addons/amxmodx/configs/plugins.ini")" -eq 1
