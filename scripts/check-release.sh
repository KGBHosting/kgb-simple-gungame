#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$ROOT_DIR/VERSION"
SOURCE="$ROOT_DIR/src/kgb_simple_gungame.sma"
CONFIG="$ROOT_DIR/configs/kgb_simple_gungame.cfg.example"
CHANGELOG="$ROOT_DIR/CHANGELOG.md"
README="$ROOT_DIR/README.md"

test -f "$VERSION_FILE"
version="$(tr -d '\r\n' < "$VERSION_FILE")"
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    printf 'VERSION must contain an exact MAJOR.MINOR.PATCH value.\n' >&2
    exit 1
fi

test "$(grep -Fxc "#define PLUGIN_VERSION \"$version\"" "$SOURCE")" -eq 1
grep -Fx "; Defaults for KGB Simple GunGame $version." "$CONFIG" >/dev/null
grep -F "The current stable source release is **$version**." "$README" >/dev/null
grep -F "## [$version] - " "$CHANGELOG" >/dev/null

if test "$#" -gt 1; then
    printf 'Usage: scripts/check-release.sh [vMAJOR.MINOR.PATCH]\n' >&2
    exit 1
fi

if test "$#" -eq 1 && test "$1" != "v$version"; then
    printf 'Release tag %s does not match source version v%s.\n' "$1" "$version" >&2
    exit 1
fi

printf 'Release metadata agrees on version %s.\n' "$version"
