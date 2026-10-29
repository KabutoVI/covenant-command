# TACTICAL Covenant vs UNSC: Architecture

Oct 28, 2026 · updated Oct 29, 2026 · @Ingo Varela

## Current status (Oct 29, 2026)

**The UNSC side has not been started.** Everything built so far targets the Covenant experience. The UNSC roster, costs, economy, reinforcements and vehicles are exactly as upstream ships them. The only things that reach UNSC players are two team-agnostic cohesion features (F6), and they are still untested with more than one player.

This is an early prototype: the mode compiles and loads, but only solo checks have been done. Nothing below has been playtested with a full lobby.

| Piece | State |
| --- | --- |
| Phase 1: setup, upstream baseline compiles on 0.9.23 | Done |
| F1 Asymmetric reinforcements (`cov_reinforcement_pct`) | Written; in-game check pending |
| F3 Covenant economy (`cov_income_pct`) | Written; in-game check pending |
| F5 Roster rework (Jackal Major as class 28, free Grunt Heavy) | Written; in-game check pending. The Major's look was changed once because it showed the minor model with an arm shield |
| F2 Squad leaders | Written, but **spawning on the leader did not work in solo tests**, so it is off by default (see E1). Slot rules and HUD remain in the code |
| F6 Team cohesion (shared kill points, ally waypoints) | Written; needs 2 or more players to test |
| F4 Call-in vehicles | Not started |
| UNSC-side design and changes | **Not started** |
| Phases 5 to 8 (vehicles, polish, playtest, publish) | Not started |

See [CHANGELOG.md](CHANGELOG.md) for how we got here and [docs/playtest-log.md](docs/playtest-log.md) for the test checklists.

The sections below are the original design. Where reality has diverged, a **Status** line says so.

## Overview

TACTICAL Covenant vs UNSC is a fork of Project Reclaimer's UNSC vs Covenant mode that makes the Covenant fun to play. It changes how Covenant players spawn, enlarges the Covenant reinforcement pool and nudges both sides toward tactical play through squads, numbers and earned vehicles, not better stats. Hard rule: no changes to health, damage or projectile speed beyond what the base mode already sets.

The problems it targets:

- **A brutal Covenant early game.** Covenant players start as free Grunts and Jackals. Those classes offer more variety than the UNSC's free classes, but they die to a single UNSC Battle Rifle burst. In canon the Covenant is an overwhelming force and the UNSC wins skirmishes through tactics and lethality; the current mode delivers neither feeling.
- **Vehicles favour the UNSC.** UNSC players take any map vehicle from spawn, while the base mode keeps Grunts and Jackals out of every vehicle seat. With equal team sizes, that vehicle support makes matches miserable for the Covenant.
- **Equal reinforcement pools.** Both factions get the same pool, though the Covenant is meant to be the swarm. This mode multiplies the Covenant pool by 1.5: 150 becomes 225 at default settings.

Design pillars:

- **Squads:** Grunt and Jackal players join a squad and respawn beside their leader. Squads follow canon roles and keep spawns balanced:
  - **Elite and Brute squads** take up to 3 Grunts (Needler or Fuel Rod) and 2 Jackals (Carbine, Shieldbearer, or a purchased Beam Rifle).
  - **Starter squads** are led by a Jackal Major with a free Beam Rifle, followed by Carbine Jackals and Grunts. Tying the only free Beam Rifle to squad leaders counters the UNSC Battle Rifle's early dominance.
  - **Earlier Elites and Brutes:** faster Covenant passive income lets players afford Elite and Brute leaders sooner.
- **Numbers:** the Covenant reinforcement pool is 1.5 times the UNSC's.
- **Earned vehicles:** map vehicles are removed; both sides call vehicles in through leader abilities with cooldowns.

Scope is Tier A only: Megalo script plus template, optionally a Forge map. AI squads are a future layer, blocked on Forge AI fixes (see Experiments and risks).

## Platform

Everything is built with Project Reclaimer's documented scripting. No binary patching, no client changes. The mode is a Megalo source file plus a JSON template, compiled by the game executable into one game mode file that only the host runs.

| Piece | Format | Runs or lives where |
| --- | --- | --- |
| Mode logic | `src/covenant-command.rvt` (ReachVariantTool Megalo subset) | Compiled; runs on the host or dedicated server only |
| Roster, options, settings | `src/template.json` (`script.logic.deployment` + `options`) | Merged into the compiled mode |
| Compiled mode | `build/covenant-command.json` | Host's `Game Modes` folder or a server's `content/Game Modes` |
| Map (optional) | Saved Forge map `.json` | Server `content/Maps`; reaches players automatically on join |

Players download nothing for the mode. They need Halo 3 campaign installed in MCC (campaign characters) and the same Project Reclaimer version as the server. Pin development to 0.9.23 and record it in `upstream/VERSION.txt`.

Toolchain commands, from the client folder:

```
$gameExe = '.\project-reclaimer-client-v0.9.23.exe'
& $gameExe megalo-check .\src\covenant-command.rvt
& $gameExe mode-compile .\src\covenant-command.rvt --template .\src\template.json --output .\build\covenant-command.json --name 'TACTICAL Covenant vs UNSC'
& $gameExe mode-check .\build\covenant-command.json
& $gameExe local-server --variant .\build\covenant-command.json
```

`mode-compile` never overwrites a file, so the build script deletes or versions the old output first.

APIs this design depends on (all documented as of 0.9.23):

- **Deployment:** `deploy_class`, `get_deployment_class()`, `get_deployment_points()`, roster `script_menu: true`.
- **Spawning:** `set_primary_respawn_object(object)`; `no_object` restores normal spawns.
- **Per-player state:** `player.player[0..3]`, `player.number[0..7]`, `player.timer[0..3]`, `player.object[0..3]`.
- **Abilities:** `on button press`, `button.ability_1..4`, `place_at_me(<vehicle or emplacement name>, …)`.
- **Effects:** `apply_traits(script_traits[n])`, `set_vehicle_use`, `set_turret_use`, `get_distance_to`.
- **UI:** `script_widget[0..31]` with per-player text and placement.

Limits to design around: 256 script-created objects at once, 32 HUD widgets, option indices assigned alphabetically, and a script error stops the script for the rest of the round.

## Base: UNSC vs Covenant

We fork the bundled mode rather than start from scratch: its class picker, deployment economy and reinforcement bars stay, and our features hook into them. Upstream files: [faction-battlefront-template.json](https://projectreclaimer.dev/modes/faction-battlefront-template.json) and [megalo-faction-battlefront.rvt](https://projectreclaimer.dev/modes/megalo-faction-battlefront.rvt).

What the template holds (read 2026-10-28):

- **Teams:** `deployment.teams` = `["UNSC", "Covenant"]`, so UNSC is team index 0 and Covenant is 1.
- **Options:** `points_per_kill` 50 (1 to 1000), `reinforcements` 150 (10 to 1000), `round_seconds` 600 (60 to 3600). One `reinforcements` value is shared by both factions.
- **Game settings:** teams on, one round, `respawn.seconds` 5, score to win 0 (the script ends the round).
- **Roster:** 28 classes, 14 per faction; a roster allows 16 per faction, so each side has 2 free class slots.
- **Class fields:** `name`, `description`, `team`, `cost`, `biped`, `model_variant`, `primary`, `secondary`, `grenades` (4 counts), `traits`, `max_active` (0 = unlimited), `camera`, optional `health` multiplier and `dual_wield`.

Covenant roster in our fork. Costs marked as changed are starting values to tune in playtests; everything else keeps upstream's loadout and cost.

| Class | Cost (upstream → ours) | Loadout change | Role |
| --- | --- | --- | --- |
| Jackal Major (new class) | new → 0 | Beam Rifle, `model_variant` major | Starter squad leader |
| Jackal Carbine Specialist | 0 → 0 | none | Follower |
| Jackal Shieldbearer | 0 → 0 | none | Follower |
| Grunt Minor | 0 → 0 | none (Needler) | Follower |
| Grunt Heavy | 100 → 0 | none (Fuel Rod) | Follower, one per squad |
| Jackal Sniper | 150 → 150 | none (Beam Rifle) | Follower |
| Brute Minor | 100 → 100 | none | Leader |
| Elite Minor | 150 → 150 | none | Leader |
| Brute Captain | 300 → 300 | none | Leader |
| Elite Major | 350 → 350 | none | Leader |
| Brute Chieftain | 450 → 450 | none | Leader |
| War Chieftain Heavy | 450 → 450 | none | Leader |
| Elite Spec Ops | 300 → 300 | none | Independent (no squad) |
| Elite Spec Ops Dualist | 300 → 300 | none | Independent |
| Hunter | 700 → 700 | none | Independent |

The Jackal Major uses one of the Covenant's 2 free roster slots. Leader prices stay at upstream values; players reach Elites and Brutes sooner through F3's faster Covenant income instead.

The `.rvt` source could not be read through the web tools (served as binary). Phase 0 downloads it locally and documents it in `docs/base-script-notes.md` before any edit: class index order, which `global` and `player` variable slots it uses, widget numbers, how reinforcements are counted and the round ended, and where per-class health and seat rules sit.

Gotcha: script options are indexed alphabetically by name (`script_option[0]` is the first name in sorted order). Adding an option can shift the indices the base script already reads, so every new option is checked against the base script's reads.

## Features

Five features; Build phases sets the order, and the mode stays playable after each one. New host options are listed per feature; names are chosen so they sort after the upstream options where possible.

### F1. Asymmetric reinforcements

The Covenant pool becomes `reinforcements × cov_reinforcement_pct / 100`.

- New option `cov_reinforcement_pct`: default 150, range 100 to 300.
- Hook: wherever the base script initialises each team's pool (found in Phase 0).
- Done when: with default options the Covenant bar starts at 225 and the UNSC bar at 150.

### F2. Squad leaders

**Status:** squad assignment, slot limits and HUD are written. The respawn-on-leader mechanic is off by default (`squad_use_leader_spawn` = 0). In solo tests on Avalanche, `set_primary_respawn_object` did not put the player beside a script-made body (spawns landed 16 to 38 units away), and a Ghost or grav lift as the anchor stopped the script. It has not been tried with 2 or more real players, so the idea is parked, not disproved.

Followers respawn beside their living leader; with no living leader they use normal spawns.

- Roles come from the roster table in Base and are looked up with `get_deployment_class()`.
- Each leader type has separate Grunt and Jackal slots:

  | Leader | Grunt slots | Jackal slots | Notes |
  | --- | --- | --- | --- |
  | Jackal Major (starter) | 2 | 2 | Starting values, tune in playtests |
  | Elite Minor, Elite Major | 3 | 2 |  |
  | Brute Minor, Captain, Chieftain, War Chieftain | 3 | 2 |  |
- Squad rules: at most one Grunt Heavy per squad. Jackal Snipers fill a Jackal slot in any squad.
- State: follower `player.player[0]` = their leader; leader keeps a Grunt count and a Jackal count in `player.number` slots chosen after Phase 0.
- Assignment: when a follower deploys without a valid leader, the script picks the Covenant leader with a free slot of the follower's type, preferring Elite and Brute squads over Jackal Major squads. No free slot means no squad: normal spawns.
- Respawn, every tick: follower's leader alive (`is_not_respawning()`) → `set_primary_respawn_object(leader.biped)`; otherwise `no_object`.
- Safe spawn: if an enemy is within `leader_spawn_safe_radius` of the leader, followers use normal spawns that tick.
- HUD: one per-player widget, "Leader: alive" or "Leader: down", plus the leader's own "Squad: %n" follower count. Widget text cannot print player names.
- New option: `leader_spawn_safe_radius` (Forge units, default from testing). Slot counts start as script constants and become options if playtests ask for it.
- Done when: in a 3-player test a Grunt and a Jackal join the same leader, respawn beside him while he moves, and fall back to normal spawns while he is dead; a second Grunt Heavy cannot join that squad.

### F3. Covenant economy

Upstream gives both factions 25 points every 30 seconds plus `points_per_kill` per kill.

- New option `cov_income_pct`: multiplies the Covenant passive income, default 150, range 100 to 300.
- Done when: a Covenant player waiting 60 seconds gains 75 points against the UNSC's 50.

### F4. Call-in vehicles

Map vehicles are removed (`map.vehicles` set to None in the game options). Vehicles enter only through abilities.

| Who | Key | Calls in | Cooldown |
| --- | --- | --- | --- |
| Elite leaders | Ability 1 | `ghost` | `vehicle_cooldown` |
| Brute leaders | Ability 1 | `chopper` | `vehicle_cooldown` |
| Grunt Heavy | Ability 1 | `plasma_cannon_emplacement` | `vehicle_cooldown` |
| ODST classes | Ability 1 | `mongoose` | `vehicle_cooldown` |
| Spartan classes | Ability 1 | `warthog` | `vehicle_cooldown` |

- One active call-in per player: the old one is deleted before the new one is placed.
- Heavy armour (`scorpion`, `wraith`) is out of scope for v1.
- `place_at_me` with a name the map lacks stops the script for the round, so the mode ships with a list of supported maps (Experiment E2).
- New option `vehicle_cooldown`: seconds, default 90, range 30 to 300.
- Done when: no vehicles spawn with the map, each listed class can call its vehicle once per cooldown, and a Grunt Heavy's emplacement is usable by Grunts.

### F5. Covenant roster rework

The roster changes in Base's table are template edits, plus one new class.

- New class `Jackal Major`: `team` 1, `cost` 0, `biped` jackal, `model_variant` major, `primary` beam\_rifle, plasma grenades as the other Jackals, traits copied from Jackal Sniper, `camera` third\_person.
- `max_active` for Jackal Major starts at 4, so a free Beam Rifle stays tied to squads instead of flooding the map.
- Cost change: Grunt Heavy drops from 100 to 0. Every other class keeps its upstream cost and loadout.
- The script's class picker draws one card per class, so the new class needs its card added wherever the base script lays out Covenant cards (found in Phase 0).
- Done when: the Covenant picker shows 15 classes, the Jackal Major spawns with a Beam Rifle at 0 points, and a fifth Jackal Major is refused while 4 are active.

### F6. Team cohesion (added Oct 29)

Added after F2's spawn mechanic failed in solo tests. It applies to both teams and does not change stats.

- **Shared kill points:** living teammates within `team_share_radius` (default 30) of a kill receive `team_share_pct` (default 50%) of its points.
- **Ally waypoints:** Covenant leaders and the UNSC Spartan classes show to their allies with a team-colour aura. Awareness only.
- New options: `team_share_pct`, `team_share_radius`.
- Done when (needs 2 or more players): a teammate near a kill gains half the reward, a far one gains nothing, and the waypoint is visible to allies but not to enemies.

## Repo layout

The project is kept under git with upstream files kept pristine so new Project Reclaimer releases can be diffed and merged.

```
covenant-command\
  README.md                  what it is, how to build, how to test
  ARCHITECTURE.md            this document, exported
  upstream\
    VERSION.txt              Project Reclaimer version the files came from
    megalo-faction-battlefront.rvt
    faction-battlefront-template.json
  src\
    covenant-command.rvt     our fork of the upstream script
    template.json            our fork of the upstream template
  build\                     compiled modes (gitignored)
  scripts\
    build.ps1                megalo-check, mode-compile, mode-check; versions old output
    deploy-local.ps1         copies the build to Game Modes and starts local-server
    play.ps1                 opens the client so you can join the local server
    update-upstream.ps1      downloads current upstream files for a diff
  playlists\                 test playlists (avalanche-test.playlist.json)
  experiments\               reserved for standalone experiment scripts (empty so far; E1 ran inside src\ via the debug build)
  maps\                      exported Forge saved maps (.json), backed up after every session
  docs\
    base-script-notes.md     planned, not written yet
    balance.md               planned, not written yet
    playtest-log.md          date, players, map, result, notes, test checklists
  CHANGELOG.md               what changed and why
```

Conventions:

- `build.ps1` takes the client executable path as a parameter or reads it from a gitignored `local.config`; nothing hardcodes a user path.
- Every change to `src/` that touches upstream logic carries a `-- CC:` comment so upstream merges can find our edits.
- `.gitignore`: `build/`, `local.config`, logs.
- Debug builds: `build.ps1 -SquadDebug` turns on the solo stand-in leader and readout; `-AnchorType` picks the stand-in object (0 ghost, 1 grav lift, 2 deployable cover).
- One commit per feature phase, tagged `phase-N` once its exit criteria pass.

## Build phases

Each phase ends playable and is tagged in git only when its exit check passes.

1. **Setup (done).** Create the repo, download upstream files, write `build.ps1` and `deploy-local.ps1`. Exit: the unmodified upstream compiles from `src/` and plays identically to the bundled mode on `local-server`.
2. **Read and probe (partly done).** Write `docs/base-script-notes.md`; run experiments E1 to E4. Exit: every experiment has a recorded result.
3. **Numbers and roster (written, in-game checks pending).** F1 asymmetric reinforcements, F3 Covenant economy, F5 roster rework. Exit: all three done-when checks pass.
4. **Squads (written; spawn mechanic parked, see E1).** F2 squad leaders. Exit: F2 done-when check passes in a 3-player test.
5. **Vehicles (not started).** F4 call-ins and the supported map list. Exit: F4 done-when check passes on every listed map.
6. **Polish (not started).** HUD text, mode description, server welcome lines. Exit: a new player understands squads and call-in keys without being told.
7. **Playtest (not started).** 8 to 16 players on our own server, options and costs tuned between rounds, results in `playtest-log.md`. Exit: the Covenant wins between 4 and 6 of 10 rounds.
8. **Publish (not started).** See Testing, hosting and publishing.

## Experiments and risks

Four unknowns are settled by small test scripts before feature work. Each lives in `experiments/` with its result written next to it.

| ID | Question | Why it matters |
| --- | --- | --- |
| E1 | Does `set_primary_respawn_object` accept a teammate's moving body, and what happens when that body dies or becomes a corpse? | F2 depends on it; a corpse reference could spawn followers on a dead leader. **Result so far (solo, Avalanche): a script-made Grunt body did not redirect spawns; Ghost and grav lift anchors stopped the script. A real 2-player test is still needed.** |
| E2 | Which target maps have `ghost`, `chopper`, `mongoose`, `warthog` and `plasma_cannon_emplacement`? | A missing name stops the script for the round |
| E3 | Do new options shift the base script's `script_option` indices? | A silent shift breaks reinforcements or kill points. **Result: yes, they shifted in Phase 3 and the reads were updated.** |
| E4 | Which `global` and `player` variable slots does the base script leave free? | F2, F4 and F5 need player numbers, timers and object slots |

Known risks:

| Risk | Effect | Mitigation |
| --- | --- | --- |
| Forge AI animations break in multiplayer (community reports, Oct 2026) | AI squads not viable yet | Out of scope for v1; revisit after a fix ships |
| Project Reclaimer releases often and pins to one engine build | Script or roster changes upstream | Pin a version; `update-upstream.ps1` plus `-- CC:` markers for merges |
| Forge maps lost to infinite loading after updates | Lost map work | Save prefabs; copy saved maps into `maps/` after every session |
| Followers spawning into a firefight around the leader | Spawn deaths, frustration | Safe spawn radius in F2 |
| 256 script-created object cap | Call-ins fail in big games | One active call-in per player; delete before placing |

Questions to post in the Project Reclaimer Discord, publicly in the modding channel:

- Is the multiplayer Forge AI animation issue known and planned for a fix?
- Can a script enable, disable or change the respawn time of a Forge AI spawner?
- Is a teammate's body supported as a `set_primary_respawn_object` target?

## Testing, hosting and publishing

The mode needs no infrastructure of its own: test locally, playtest on our own PC, then hand the file to existing community servers.

**Local testing.** `deploy-local.ps1` runs `local-server --variant` and the client joins from the Server Browser. Multi-player checks (F2, F5) need a second player or PC. Every test covers: first deploy, death and respawn, a leader dying and leaving, a second round, and a player joining mid-round.

**Playtest server (own PC).** A dedicated server from `dedicated init`, one `[[server]]` running the compiled mode on the chosen map, `max_players` 16, `min_players` 8. Ports: UDP 49176 for the game, TCP 49175 for the master; UPnP or forwarding, with the masters' hole punching as a fallback. Upload need is roughly 60 KB/s per player, so about 8 Mbit/s at 16 players. Up to 5 `welcome` lines explain squads and call-in keys.

**What players see.** The server in the browser with its name, map, game type and player count; the mode's name and description on the loading screen. Nothing to download beyond the Halo 3 campaign and the matching Project Reclaimer version.

**Publishing.**

1. Post the compiled mode, the supported map list and a short clip in the Discord's modding channel.
2. Offer the file to server operators and to mappers already building UNSC vs Covenant maps; a server only needs the file in `content/Game Modes`.
3. Keep our own server listed at Mexico evening hours as the mode's home.
4. Once stable, propose it to the developers as a bundled mode.

## Sources

- [Project Reclaimer home](https://projectreclaimer.dev/)
- [Megalo scripts guide](https://projectreclaimer.dev/megalo.html)
- [Game modes and scripting](https://projectreclaimer.dev/modes.html)
- [Host a dedicated server](https://projectreclaimer.dev/host.html)
- [UNSC vs Covenant template](https://projectreclaimer.dev/modes/faction-battlefront-template.json)
