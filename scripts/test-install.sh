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

# This script is already the release workflow's post-build test entry point.
# Keep package reproducibility in that gate without changing the release flow.
"$ROOT_DIR/scripts/test-package-reproducibility.sh" "${PACKAGE_TEST_VERSION:-reproducibility-test}"

package_version="${PACKAGE_TEST_VERSION:-reproducibility-test}"
package_extract="$(mktemp -d)"
package_target="$(mktemp -d)"
trap 'rm -rf "$target" "$package_extract" "$package_target"' EXIT
unzip -q "$ROOT_DIR/dist/kgb-simple-gungame-$package_version.zip" -d "$package_extract"
package_root="$package_extract/kgb-simple-gungame-$package_version"
source_version="$(tr -d '\r\n' < "$ROOT_DIR/VERSION")"
test "$(tr -d '\r\n' < "$package_root/VERSION")" = "$source_version"
if command -v sha256sum >/dev/null 2>&1; then
    (cd "$package_root/compiled" && sha256sum --check kgb_simple_gungame.amxx.sha256)
else
    (cd "$package_root/compiled" && shasum -a 256 -c kgb_simple_gungame.amxx.sha256)
fi
"$package_root/scripts/install.sh" "$package_target"
"$package_root/scripts/install.sh" "$package_target"
cmp "$package_root/compiled/kgb_simple_gungame.amxx" \
    "$package_target/addons/amxmodx/plugins/kgb_simple_gungame.amxx"
test "$(grep -Ec '^[[:space:]]*kgb_simple_gungame\.amxx([[:space:]]|$)' "$package_target/addons/amxmodx/configs/plugins.ini")" -eq 1
