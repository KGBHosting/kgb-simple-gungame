#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:?Usage: scripts/package.sh <version>}"
PACKAGE="kgb-simple-gungame-$VERSION"
STAGE="$ROOT_DIR/dist/$PACKAGE"

rm -rf "$STAGE" "$ROOT_DIR/dist/$PACKAGE.zip" "$ROOT_DIR/dist/$PACKAGE.zip.sha256"
mkdir -p "$STAGE/compiled" "$STAGE/configs" "$STAGE/scripts" "$STAGE/src"
cp "$ROOT_DIR/LICENSE" "$ROOT_DIR/README.md" "$ROOT_DIR/SECURITY.md" "$STAGE/"
cp "$ROOT_DIR/compiled/kgb_simple_gungame.amxx" "$ROOT_DIR/compiled/kgb_simple_gungame.amxx.sha256" "$STAGE/compiled/"
cp "$ROOT_DIR/configs/kgb_simple_gungame.cfg.example" "$STAGE/configs/"
cp "$ROOT_DIR/scripts/install.sh" "$STAGE/scripts/"
cp "$ROOT_DIR/src/kgb_simple_gungame.sma" "$STAGE/src/"

(cd "$ROOT_DIR/dist" && zip -qr "$PACKAGE.zip" "$PACKAGE")
if command -v sha256sum >/dev/null 2>&1; then
    (cd "$ROOT_DIR/dist" && sha256sum "$PACKAGE.zip" > "$PACKAGE.zip.sha256")
else
    (cd "$ROOT_DIR/dist" && shasum -a 256 "$PACKAGE.zip" > "$PACKAGE.zip.sha256")
fi
