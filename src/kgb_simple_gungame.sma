// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Lukasz Zajac
// Copyright (c) 2026 KGB Hosting
//
// Adapted from Simple GunGame 1.0.9 at immutable upstream commit
// 3925801ddadc9d623bc1586f79e1c8bee194aa2d. This managed edition removes
// custom media, CSR natives, map-prefix restrictions, and runtime map-vote
// integrations so the plugin is self-contained and safe for catalog install.

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>

#define PLUGIN_NAME "KGB Simple GunGame"
#define PLUGIN_VERSION "0.1.0"
#define PLUGIN_AUTHOR "ToRRent / KGB Hosting"

#define TASK_EQUIP_BASE 48100
#define TASK_RESTART 48200

static const g_WeaponEntities[][] = {
    "weapon_glock18",
    "weapon_usp",
    "weapon_p228",
    "weapon_deagle",
    "weapon_fiveseven",
    "weapon_elite",
    "weapon_m3",
    "weapon_xm1014",
    "weapon_tmp",
    "weapon_mac10",
    "weapon_mp5navy",
    "weapon_ump45",
    "weapon_p90",
    "weapon_galil",
    "weapon_famas",
    "weapon_ak47",
    "weapon_scout",
    "weapon_m4a1",
    "weapon_sg552",
    "weapon_aug",
    "weapon_m249",
    "weapon_hegrenade",
    "weapon_knife"
}

static const g_WeaponLabels[][] = {
    "Glock 18",
    "USP",
    "P228",
    "Desert Eagle",
    "Five-SeveN",
    "Dual Elites",
    "M3",
    "XM1014",
    "TMP",
    "MAC-10",
    "MP5 Navy",
    "UMP45",
    "P90",
    "Galil",
    "Famas",
    "AK-47",
    "Scout",
    "M4A1",
    "SG552",
    "AUG",
    "M249",
    "HE Grenade",
    "Knife"
}

new g_Level[33]
new g_KillsOnLevel[33]
new bool:g_MatchEnding
new g_MaxPlayers

new g_CvarEnabled
new g_CvarKillsPerLevel
new g_CvarArmor
new g_CvarDisplayName
new g_CvarChatPrefix

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
    register_cvar("kgb_gg_version", PLUGIN_VERSION, FCVAR_SERVER | FCVAR_SPONLY)

    g_CvarEnabled = register_cvar("kgb_gg_enabled", "1")
    g_CvarKillsPerLevel = register_cvar("kgb_gg_kills_per_level", "1")
    g_CvarArmor = register_cvar("kgb_gg_armor", "100")
    g_CvarDisplayName = register_cvar("kgb_gg_display_name", "GunGame")
    g_CvarChatPrefix = register_cvar("kgb_gg_chat_prefix", "[GunGame]")
    g_MaxPlayers = get_maxplayers()

    register_event("DeathMsg", "event_death", "a")
    RegisterHam(Ham_Spawn, "player", "player_spawned", 1)

    register_clcmd("say /level", "command_level")
    register_clcmd("say_team /level", "command_level")
    register_clcmd("say /gg", "command_level")
    register_clcmd("say_team /gg", "command_level")
    register_concmd("amx_kgb_gg_setlevel", "command_set_level", ADMIN_BAN, "<player> <level>")
    register_srvcmd("kgb_gg_status", "command_status")
    register_srvcmd("kgb_gg_license", "command_license")
}

public plugin_cfg()
{
    new configDir[128]
    get_configsdir(configDir, charsmax(configDir))
    server_cmd("exec %s/kgb_simple_gungame.cfg", configDir)
    server_exec()
}

public client_putinserver(id)
{
    resetPlayer(id)
}

public client_disconnected(id)
{
    remove_task(TASK_EQUIP_BASE + id)
    resetPlayer(id)
}

public player_spawned(id)
{
    if (!isModeEnabled() || !is_user_alive(id) || !isPlaying(id)) {
        return
    }

    scheduleEquip(id)
}

public event_death()
{
    if (!isModeEnabled() || g_MatchEnding) {
        return
    }

    new killer = read_data(1)
    new victim = read_data(2)

    if (killer < 1 || killer > g_MaxPlayers || killer == victim || !is_user_connected(killer)) {
        return
    }

    new weapon[24]
    read_data(4, weapon, charsmax(weapon))

    if (!isExpectedWeapon(killer, weapon)) {
        return
    }

    new killsRequired = clamp(get_pcvar_num(g_CvarKillsPerLevel), 1, 10)
    g_KillsOnLevel[killer]++

    if (g_KillsOnLevel[killer] < killsRequired) {
        showProgress(killer)
        return
    }

    g_KillsOnLevel[killer] = 0
    g_Level[killer]++

    if (g_Level[killer] >= sizeof(g_WeaponEntities)) {
        finishMatch(killer)
        return
    }

    announceLevel(killer)
    if (is_user_alive(killer)) {
        scheduleEquip(killer)
    }
}

public equip_task(taskId)
{
    new id = taskId - TASK_EQUIP_BASE
    if (!isModeEnabled() || !is_user_alive(id) || !isPlaying(id)) {
        return
    }

    equipPlayer(id)
}

public restart_match()
{
    g_MatchEnding = false

    for (new id = 1; id <= g_MaxPlayers; id++) {
        if (is_user_connected(id)) {
            resetPlayer(id)
        }
    }

    server_cmd("sv_restart 1")
}

public command_level(id)
{
    if (!is_user_connected(id)) {
        return PLUGIN_HANDLED
    }

    showProgress(id)
    return PLUGIN_HANDLED
}

public command_set_level(id, level, commandId)
{
    if (!cmd_access(id, level, commandId, 3)) {
        return PLUGIN_HANDLED
    }

    new targetArg[32]
    new levelArg[12]
    read_argv(1, targetArg, charsmax(targetArg))
    read_argv(2, levelArg, charsmax(levelArg))

    new target = cmd_target(id, targetArg, CMDTARGET_ALLOW_SELF)
    if (!target) {
        return PLUGIN_HANDLED
    }

    new requested = clamp(str_to_num(levelArg), 1, sizeof(g_WeaponEntities))
    g_Level[target] = requested - 1
    g_KillsOnLevel[target] = 0

    if (is_user_alive(target)) {
        scheduleEquip(target)
    }

    console_print(id, "Set GunGame level for player #%d to %d.", get_user_userid(target), requested)
    return PLUGIN_HANDLED
}

public command_status()
{
    new displayName[48]
    safeCvarText(g_CvarDisplayName, displayName, charsmax(displayName), "GunGame")
    server_print("%s %s: enabled=%d levels=%d kills_per_level=%d ending=%d",
        displayName,
        PLUGIN_VERSION,
        isModeEnabled(),
        sizeof(g_WeaponEntities),
        clamp(get_pcvar_num(g_CvarKillsPerLevel), 1, 10),
        g_MatchEnding
    )
}

public command_license()
{
    server_print("KGB Simple GunGame %s", PLUGIN_VERSION)
    server_print("Copyright (c) 2026 Lukasz Zajac")
    server_print("Copyright (c) 2026 KGB Hosting")
    server_print("MIT License: Permission is hereby granted, free of charge, to any person obtaining a copy")
    server_print("of this software and associated documentation files (the Software), to deal in the Software")
    server_print("without restriction, including without limitation the rights to use, copy, modify, merge,")
    server_print("publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons")
    server_print("to whom the Software is furnished to do so, subject to the following conditions:")
    server_print("The above copyright notice and this permission notice shall be included in all copies")
    server_print("or substantial portions of the Software.")
    server_print("THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,")
    server_print("INCLUDING BUT NOT LIMITED TO MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.")
    server_print("IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER")
    server_print("LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN")
    server_print("CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.")
}

stock scheduleEquip(id)
{
    remove_task(TASK_EQUIP_BASE + id)
    set_task(0.2, "equip_task", TASK_EQUIP_BASE + id)
}

stock equipPlayer(id)
{
    new level = clamp(g_Level[id], 0, sizeof(g_WeaponEntities) - 1)
    new weaponId = get_weaponid(g_WeaponEntities[level])

    strip_user_weapons(id)
    give_item(id, "weapon_knife")

    if (!equal(g_WeaponEntities[level], "weapon_knife")) {
        give_item(id, g_WeaponEntities[level])
    }

    if (weaponId > 0) {
        cs_set_user_bpammo(id, weaponId, weaponId == CSW_HEGRENADE ? 1 : 200)
    }

    cs_set_user_armor(id, clamp(get_pcvar_num(g_CvarArmor), 0, 100), CS_ARMOR_VESTHELM)
    showProgress(id)
}

stock bool:isExpectedWeapon(id, const weapon[])
{
    new level = clamp(g_Level[id], 0, sizeof(g_WeaponEntities) - 1)
    new expected[24]
    copy(expected, charsmax(expected), g_WeaponEntities[level])
    replace(expected, charsmax(expected), "weapon_", "")

    if (equal(expected, "hegrenade")) {
        return bool:(equal(weapon, "grenade") || equal(weapon, "hegrenade"))
    }

    return bool:equal(weapon, expected)
}

stock finishMatch(winner)
{
    g_MatchEnding = true
    remove_task(TASK_RESTART)

    new winnerName[32]
    new prefix[32]
    get_user_name(winner, winnerName, charsmax(winnerName))
    safeCvarText(g_CvarChatPrefix, prefix, charsmax(prefix), "[GunGame]")
    client_print(0, print_chat, "%s %s won the match. A new match starts in 5 seconds.", prefix, winnerName)

    set_task(5.0, "restart_match", TASK_RESTART)
}

stock announceLevel(id)
{
    new playerName[32]
    new prefix[32]
    get_user_name(id, playerName, charsmax(playerName))
    safeCvarText(g_CvarChatPrefix, prefix, charsmax(prefix), "[GunGame]")
    client_print(0, print_chat, "%s %s advanced to level %d/%d: %s.",
        prefix,
        playerName,
        g_Level[id] + 1,
        sizeof(g_WeaponEntities),
        g_WeaponLabels[g_Level[id]]
    )
}

stock showProgress(id)
{
    new level = clamp(g_Level[id], 0, sizeof(g_WeaponEntities) - 1)
    new killsRequired = clamp(get_pcvar_num(g_CvarKillsPerLevel), 1, 10)
    new displayName[48]
    safeCvarText(g_CvarDisplayName, displayName, charsmax(displayName), "GunGame")

    set_hudmessage(255, 160, 32, -1.0, 0.83, 0, 0.0, 3.0, 0.1, 0.2, -1)
    show_hudmessage(id, "%s | Level %d/%d | %s | %d/%d kills",
        displayName,
        level + 1,
        sizeof(g_WeaponEntities),
        g_WeaponLabels[level],
        g_KillsOnLevel[id],
        killsRequired
    )
}

stock resetPlayer(id)
{
    g_Level[id] = 0
    g_KillsOnLevel[id] = 0
}

stock bool:isPlaying(id)
{
    new CsTeams:team = cs_get_user_team(id)
    return team == CS_TEAM_T || team == CS_TEAM_CT
}

stock bool:isModeEnabled()
{
    return get_pcvar_num(g_CvarEnabled) != 0
}

stock safeCvarText(cvar, output[], outputLength, const fallback[])
{
    get_pcvar_string(cvar, output, outputLength)
    trim(output)

    if (!output[0] || containsUnsafeText(output)) {
        copy(output, outputLength, fallback)
    }
}

stock bool:containsUnsafeText(const value[])
{
    for (new index = 0; value[index]; index++) {
        if (value[index] < 32 || value[index] > 126 || value[index] == ';' || value[index] == '^"' || value[index] == 92) {
            return true
        }
    }

    return false
}
