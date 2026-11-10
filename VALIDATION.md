## 1.0.1 restart guard

The v1.0.0 win callback reset levels and unlocked progression before `sv_restart 1`
finished the engine restart. A valid Glock kill during that interval could carry
level 2 into the next match. The 1.0.1 callback keeps the ending guard set until
ReGameDLL emits the actual `HLTV(0,0)` new-round event, synchronously before
player respawns; normal non-winning round restarts keep existing progression.

Primary source ordering: ReGameDLL commit
`70307312cde05cec5d73a3d3a384b4bdac3d5fe2`,
`regamedll/dlls/multiplay_gamerules.cpp` lines 1730-1733, 2047, 3129-3169;
AMXX 1.9.0.5303 commit `b88b763a63bc7165f48e326c226eb05f9db0e54a`,
`amxmodx/meta_api.cpp` lines 1402-1407.

Live regression gate: use two controlled players, keep one at Glock level 1,
win with the other's knife, then land a valid Glock kill after the five-second
callback but before the engine actually restarts. The ending guard must remain
set, and both players must start the next match at level 1 with Glock loadouts.
Also test an operator-triggered early restart and an ordinary non-winning
round restart. Engine instrumentation and bots must be identified as test
doubles and do not replace real Valve-client gameplay qualification.

This section records source reasoning and the live test plan, not a completed
runtime or Valve-client result. The historical evidence below applies only to
its stated versions.

# Validation status

This document separates automated compatibility checks, live server evidence,
and work that still needs a licensed Valve client.

## Automated release gates

The repository compiles the same source against AMX Mod X 1.8.2, 1.9, and
1.10. The release binary is compiled with 1.8.2. CI checks the required modules,
disconnect-forward compatibility, source/tag version agreement, binary format,
binary and archive checksums, idempotent installation, packaged installation,
and byte-for-byte ZIP reproducibility across different time zones and umasks.

## Live development qualification

The 0.1.1 gameplay source promoted to 1.0.0 was exercised on 2026-08-29 on a
disposable KGB development ReHLDS 3.15.0.896-dev server with YaPB bots. The
server reported the plugin running and all 23 levels available.

Confirmed server-side behavior:

- clean managed install, health verification, uninstall, reinstall, and final
  cleanup;
- four active bots on `de_dust2`;
- a knife kill at level 1 was rejected, followed by exact Glock and USP
  progression;
- exact mid-ladder progression from UMP45 through subsequent weapons;
- a knife kill at level 22 did not finish the match;
- a final-level knife kill caused an exact five-second restart and reset the
  next match to Glock.

The HE-grenade progression attempt was bounded but inconclusive because the
target bot did not produce an HE kill. No HE success is claimed.

## Remaining Valve-client acceptance

Before representing every customer-visible path as proven, use licensed
Valve Steam CS1.6 clients on a disposable server to check:

- HE-grenade progression and the missed-grenade recovery experience;
- HUD and chat rendering, `/level`, and `/gg`;
- visible loadouts, armor, and respawn behavior;
- configurable display name and chat prefix;
- admin authorization and denial for `amx_kgb_gg_setlevel`;
- reconnect behavior and self/world-kill rejection in live play;
- a clean client join with no custom download prompts.

These gaps do not change the documented server-side behavior, but they mean the
release must not be described as fully Valve-client-qualified.
