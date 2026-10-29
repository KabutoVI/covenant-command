# Changelog

All dates are 2026. Times are local. The project went from scaffold to a playable prototype between the evening of Oct 28 and early Oct 29. Everything so far is **Covenant-focused; UNSC-side work has not started.**

## Oct 29, 00:00 to 00:52: squad spawn experiments fail, cohesion features added

- Tried to make followers respawn beside a stand-in leader (a script-made body) with a debug readout showing distances at death, spawn and now. Spawns landed 16 to 38 units from the stand-in in solo tests on Avalanche, so the engine call did not do what the design assumed (E1).
- Tried a Ghost, a permanent grav lift and deployable cover as the anchor object. Unavailable objects stop the whole script on that map, so the debug build now uses one object type per build (`-AnchorType`).
- Added a test playlist for Avalanche; `deploy-local` copies the compiled mode into the game's mode folder.
- **Direction change:** respawn-on-leader is off by default (`squad_use_leader_spawn` = 0), with the code kept for a 2+ player test. Replaced by team cohesion features that apply to both teams:
  - shared kill points (`team_share_pct`, `team_share_radius`)
  - ally waypoints with a team-colour aura for Covenant leaders and the UNSC Spartan classes

## Oct 28, 23:37 to 23:58: squad leaders (Phase 4)

- Squad leaders: Grunts and Jackals join a Covenant leader with per-type slot limits, one Grunt Heavy per squad, a leader HUD line and a safe-radius fallback. Spawn-on-leader mechanic included but untested at the time.
- Solo debug mode (`squad_debug`, `build.ps1 -SquadDebug`) substitutes a script-made Grunt as leader.
- Jackal Major: tried a shieldless look because the major look showed the minor model with an arm shield.

## Oct 28, 23:25 to 23:32: numbers and roster (Phase 3)

- Added `cov_reinforcement_pct` (default 150) and `cov_income_pct` (default 150).
- Added the Jackal Major as a 15th Covenant class (max 4 active, free Beam Rifle) with its picker card.
- Grunt Heavy cost 100 to 0.
- New options shifted the script's alphabetical option indices; all reads were updated (answers E3).

## Oct 28, 23:18 to 23:25: setup (Phase 1)

- Repo scaffold, architecture doc, build and deploy scripts, playtest log.
- Recorded the confirmed client version, 0.9.23.
- Added the pristine upstream files and an unmodified `src` baseline that compiles on 0.9.23.
- Playtest tooling: `play.ps1`, MCC path passed to `deploy-local`.

## Not started

- UNSC-side design and changes (roster, economy, reinforcements, vehicles)
- Call-in vehicles (F4)
- Polish, full-lobby playtests, publishing
