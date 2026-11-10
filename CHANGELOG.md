# Changelog

All notable changes to KGB Simple GunGame are documented here. Versions follow
[Semantic Versioning](https://semver.org/).

## [1.0.2] - 2026-11-10

- Skip backpack ammunition for the final knife level, which has no ammo slot.
- Preserve final-level armor and HUD setup without a CStrike native error.

## [1.0.1] - 2026-11-10

- Keep progression locked throughout the engine restart delay after a win.
- Reset the ladder at the actual new-round event before player respawns.
- Cancel the queued win restart if an operator restarts the round earlier.
- Describe the winner display without promising an exact engine restart time.

## [1.0.0] - 2026-08-29

First stable release. Gameplay is unchanged from the development-qualified
0.1.1 candidate.

- Fixed 23-level stock-weapon ladder with exact-weapon kill validation.
- Configurable kills per level, spawn armor, display name, and chat prefix.
- Player progress HUD and `/level` or `/gg` chat commands.
- `ADMIN_BAN`-gated level override and server-console status/license commands.
- Five-second match restart after the final knife level.
- Idempotent AMX Mod X 1.8.2, 1.9, and 1.10 disconnect cleanup.
- Media-free installation with no custom client downloads.
- Reproducible release ZIP, checksum manifest, and source/tag version gates.

Known validation gaps and behavioral limits are tracked in
[VALIDATION.md](VALIDATION.md) and [README.md](README.md).

## [0.1.1] - 2026-08-27

- Added compatible disconnect cleanup for AMX Mod X 1.8.2, 1.9, and 1.10.

## [0.1.0] - 2026-08-27

- Published the initial prerelease adaptation of Simple GunGame 1.0.9.

[1.0.1]: https://github.com/KGBHosting/kgb-simple-gungame/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/KGBHosting/kgb-simple-gungame/compare/v0.1.1...v1.0.0
[0.1.1]: https://github.com/KGBHosting/kgb-simple-gungame/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/KGBHosting/kgb-simple-gungame/releases/tag/v0.1.0
