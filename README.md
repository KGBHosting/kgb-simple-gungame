# KGB Simple GunGame

KGB Simple GunGame is a media-free AMX Mod X weapon-ladder mode for
Counter-Strike 1.6. It is usable by any server operator; no KGB Hosting account
or KGB-specific runtime is required. Server owners can change the visible name
and chat prefix in the supplied configuration.

The current stable source release is **1.0.0**. Release tags, source metadata,
configuration documentation, and packaged assets are checked for version
agreement before GitHub can publish a release.

This is a maintained adaptation of [Simple GunGame 1.0.9](https://github.com/ToRRent1812/amxx-simple-gungame/tree/3925801ddadc9d623bc1586f79e1c8bee194aa2d).
The fork removes custom media, CSR natives, map-prefix restrictions, and runtime
map-vote integrations. It retains the upstream MIT license and copyright.

## Features

- 23-level stock-weapon ladder from Glock 18 through knife.
- Exact-weapon kill validation and configurable kills per level.
- Spawn loadout restoration, armor, HUD progress, and `/level` or `/gg` status.
- Configurable display name and chat prefix.
- Admin level override through `amx_kgb_gg_setlevel`.
- Bounded five-second restart after a winner completes the ladder.
- No custom sounds, models, sprites, or other client downloads.

## Exact gameplay behavior

- Every connected T or CT player starts at level 1; spectators are ignored.
- Only a kill reported with the player's current ladder weapon advances that
  player. Self-kills and world kills do not advance the ladder.
- With friendly fire enabled, a team kill reported with the expected weapon
  counts like any other kill. The plugin does not add a separate team-kill
  penalty.
- The plugin replaces a player's weapons and grants the configured armor after
  spawn. It does not itself force respawns, make rounds infinite, or change buy
  rules; KGB's recommended gamemode recipe supplies those ReGameDLL settings.
- Progress is in memory only. Disconnecting, a map/server restart, or the
  five-second post-win restart resets progress.
- The HE level grants one grenade on spawn. A missed grenade is not replenished
  while the player remains alive; the next spawn restores the level loadout.
- The weapon ladder is fixed in this release. Kills per level, spawn armor,
  visible name, and chat prefix are configurable.

## Requirements

- Counter-Strike 1.6.
- AMX Mod X 1.8.2, 1.9, or 1.10.
- The AMX Mod X Counter-Strike, Fun, and Ham Sandwich modules.
- ReGameDLL is required for the recommended continuous-respawn gamemode recipe,
  but the plugin itself does not link to ReAPI.

CI compiles the same source against all three supported AMX Mod X lines. It
also verifies the legacy `client_disconnect` forward required by 1.8.2 and the
newer `client_disconnected` forward, with both routed through one idempotent
cleanup helper. The release binary is built with 1.8.2 for the widest supported
runtime range.

## Install

Download the release bundle and run:

```sh
./scripts/install.sh /path/to/cstrike
```

The installer copies the plugin, writes the default configuration only when it
is missing, installs the MIT notice under `addons/amxmodx/licenses/`, and adds
one idempotent entry to `addons/amxmodx/configs/plugins.ini`.

KGB Platform customers should install the plugin through the Panel plugin
manager or deploy the GunGame gamemode recipe. The gamemode bundle never
contains the plugin binary.

## Commands

| Command | Access | Description |
| --- | --- | --- |
| `say /level` or `say /gg` | Player | Show current ladder progress. |
| `amx_kgb_gg_setlevel <player> <level>` | `ADMIN_BAN` | Set a player's level. |
| `kgb_gg_status` | Server console/RCON | Print runtime health and settings. |
| `kgb_gg_license` | Server console/RCON | Print the embedded MIT notice. |

## Configuration

| Cvar | Default | Description |
| --- | --- | --- |
| `kgb_gg_enabled` | `1` | Enable GunGame logic. |
| `kgb_gg_kills_per_level` | `1` | Kills needed per level, clamped to 1-10. |
| `kgb_gg_armor` | `100` | Spawn armor, clamped to 0-100. |
| `kgb_gg_display_name` | `GunGame` | HUD and status name. |
| `kgb_gg_chat_prefix` | `[GunGame]` | Chat prefix. |

Unsafe control characters and command separators in visible text fall back to
the defaults.

## Build and test

Docker is required. Compiler archives and the build container are checksum or
digest pinned.

```sh
./scripts/check-compatibility.sh
./scripts/check-release.sh
./scripts/build.sh
./scripts/test-install.sh
```

See [VALIDATION.md](VALIDATION.md) for the live development evidence and the
remaining client-visible acceptance gaps. Compiler success and bot-backed
server checks are not substitutes for Valve-client proof.

## Known limits

- The ladder order is not configurable without recompiling the plugin.
- Ladder progress is not persisted across disconnects or restarts; normal
  scoreboard scores remain governed by the server and its restart settings.
- Respawn timing and continuous-round behavior belong to the server's
  ReGameDLL configuration, not this plugin.
- There is no built-in warmup, team balancing, map voting, statistics storage,
  web API, sound pack, or custom-media system.
- A full licensed Valve-client pass is still required for HUD/chat rendering,
  admin authorization, branding, reconnect behavior, and the HE level. These
  gaps are recorded in [VALIDATION.md](VALIDATION.md).

Maintainers should follow [RELEASING.md](RELEASING.md); version tags are
immutable release inputs and are created only from a fully checked `main`
commit.

## License

MIT. See [LICENSE](LICENSE).
