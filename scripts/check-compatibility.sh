#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for version in 1.8.2 1.9 1.10; do
    printf '\n== AMX Mod X %s ==\n' "$version"
    AMXX_VERSION="$version" "$ROOT_DIR/scripts/build.sh"
    AMXX_VERSION="$version" "$ROOT_DIR/scripts/check-runtime-compatibility.sh"
done
