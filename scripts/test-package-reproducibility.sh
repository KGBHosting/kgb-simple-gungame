#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-reproducibility-test}"
ARCHIVE="$ROOT_DIR/dist/kgb-simple-gungame-$VERSION.zip"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

test -s "$ROOT_DIR/compiled/kgb_simple_gungame.amxx"
test -s "$ROOT_DIR/compiled/kgb_simple_gungame.amxx.sha256"

(umask 0022; TZ=Pacific/Honolulu "$ROOT_DIR/scripts/package.sh" "$VERSION")
cp "$ARCHIVE" "$TEMP_DIR/first.zip"

# ZIP stores timestamps at two-second resolution. Ensure an unnormalized second
# build would differ, while also exercising a restrictive process umask.
sleep 3
(umask 0077; TZ=Europe/Brussels "$ROOT_DIR/scripts/package.sh" "$VERSION")
cp "$ARCHIVE" "$TEMP_DIR/second.zip"

cmp "$TEMP_DIR/first.zip" "$TEMP_DIR/second.zip"

if command -v sha256sum >/dev/null 2>&1; then
    first_hash="$(sha256sum "$TEMP_DIR/first.zip" | awk '{print $1}')"
    second_hash="$(sha256sum "$TEMP_DIR/second.zip" | awk '{print $1}')"
else
    first_hash="$(shasum -a 256 "$TEMP_DIR/first.zip" | awk '{print $1}')"
    second_hash="$(shasum -a 256 "$TEMP_DIR/second.zip" | awk '{print $1}')"
fi

test "$first_hash" = "$second_hash"
printf 'Reproducible package SHA-256: %s\n' "$first_hash"
