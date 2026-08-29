#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:?Usage: scripts/package.sh <version>}"
if [[ ! "$VERSION" =~ ^[A-Za-z0-9][A-Za-z0-9._+-]*$ ]]; then
    printf 'Unsafe package version: %s\n' "$VERSION" >&2
    exit 1
fi
PACKAGE="kgb-simple-gungame-$VERSION"
STAGE="$ROOT_DIR/dist/$PACKAGE"
ARCHIVE="$ROOT_DIR/dist/$PACKAGE.zip"
CHECKSUM="$ARCHIVE.sha256"

# ZIP timestamps have a 1980 lower bound. Fix every staged entry to that value
# and normalize permissions so checkout time, local umask, uid/gid, and host
# filesystem metadata cannot change the release archive.
ZIP_TIMESTAMP="198001010000.00"

rm -rf "$STAGE" "$ARCHIVE" "$CHECKSUM"
mkdir -p "$STAGE/compiled" "$STAGE/configs" "$STAGE/scripts" "$STAGE/src"
COPYFILE_DISABLE=1 cp \
    "$ROOT_DIR/CHANGELOG.md" \
    "$ROOT_DIR/LICENSE" \
    "$ROOT_DIR/README.md" \
    "$ROOT_DIR/RELEASING.md" \
    "$ROOT_DIR/SECURITY.md" \
    "$ROOT_DIR/VALIDATION.md" \
    "$ROOT_DIR/VERSION" \
    "$STAGE/"
COPYFILE_DISABLE=1 cp "$ROOT_DIR/compiled/kgb_simple_gungame.amxx" "$ROOT_DIR/compiled/kgb_simple_gungame.amxx.sha256" "$STAGE/compiled/"
COPYFILE_DISABLE=1 cp "$ROOT_DIR/configs/kgb_simple_gungame.cfg.example" "$STAGE/configs/"
COPYFILE_DISABLE=1 cp "$ROOT_DIR/scripts/install.sh" "$STAGE/scripts/"
COPYFILE_DISABLE=1 cp "$ROOT_DIR/src/kgb_simple_gungame.sma" "$STAGE/src/"

find "$STAGE" -type d -exec chmod 0755 {} +
find "$STAGE" -type f -exec chmod 0644 {} +
chmod 0755 "$STAGE/scripts/install.sh"
TZ=UTC find "$STAGE" -exec touch -t "$ZIP_TIMESTAMP" {} +

(
    cd "$ROOT_DIR/dist"
    export LC_ALL=C TZ=UTC
    find "$PACKAGE" -print | sort | zip -X -q "$PACKAGE.zip" -@
)
if command -v sha256sum >/dev/null 2>&1; then
    (cd "$ROOT_DIR/dist" && sha256sum "$PACKAGE.zip" > "$PACKAGE.zip.sha256")
else
    (cd "$ROOT_DIR/dist" && shasum -a 256 "$PACKAGE.zip" > "$PACKAGE.zip.sha256")
fi
