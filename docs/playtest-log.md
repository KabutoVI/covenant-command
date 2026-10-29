# Playtest log

One row per session. Keep captured logs outside this repo and redact personal identifiers before sharing.

| Date | Players | Map | Build (commit) | Result | Notes |
| --- | --- | --- | --- | --- | --- |

## Baseline checklist (unmodified upstream, Phase 1 exit)
- [ ] Server starts, client joins from the Server Browser
- [ ] Class picker shows 14 UNSC / 14 Covenant classes
- [ ] First deploy, death, respawn (5 s)
- [ ] Reinforcement bars start at 150 / 150
- [ ] Round ends when a pool hits zero or the 600 s timer ends
- [ ] Second round starts; mid-round join works

## Phase 3 checklist (F1, F3, F5)
- [ ] Covenant reinforcement bar starts at 225, UNSC at 150
- [ ] Covenant waiting 60 s gains about 76 points (UNSC gains 50)
- [ ] Covenant picker shows 15 cards; Jackal Major (FREE, Beam Rifle) in row 4, third column
- [ ] Jackal Major refused when 4 are already active
- [ ] Grunt Heavy shows FREE and deploys at 0 points
- [ ] Kill points still 50 per kill; round still 600 s (option indices not shifted wrongly)

## Phase 4 solo test (build with `scripts\build.ps1 -SquadDebug`)
A stand-in Grunt body acts as leader: it walks back and forth and is deleted 15 s of every 60 s.
- [ ] Pick Grunt Minor or a Jackal; HUD shows "Leader: alive"
- [ ] Die while it is alive: you respawn next to it (E1: moving body accepted?)
- [ ] Die while it is deleted: HUD "Leader: down", you get a normal spawn (E1: no spawn on a corpse)
- [ ] Jackal Major / Elite / Brute: HUD shows "Squad: 0 followers"
- [ ] Any script fault or odd leader behaviour (note it here)
Real multi-player squad assignment (slot limits, one Grunt Heavy) is written but cannot be tested solo.

## E1 result so far (2026-10-29, Avalanche, solo, stand-in Grunt body)
Readout "died X, spawned Y": 33/38, 39/16, 38/28. Spawned 16-38 units from the stand-in, so
set_primary_respawn_object did NOT put the player beside the script-made Grunt body (normal
spawns). Next: same test with a Ghost as the anchor (object type may matter).

## Direction change (2026-10-29)
Leader-body/anchor respawn did not redirect spawns in solo tests (Grunt body: spawned 16-38 units away) and
Ghost/grav-lift anchors stopped the script on Avalanche. Squad respawn is now OFF by default
(option squad_use_leader_spawn = 0); code kept for a later 2+ player test. Debug anchor only with squad_debug.
New cohesion features instead, both teams:
- Shared kill points: living teammates within team_share_radius (30) get team_share_pct (50%) of a kill's points.
- Squad waypoints: Covenant leaders and UNSC Spartan classes get waypoint(allies) + team-colour aura.
Checklist (need 2+ players to see them):
- [ ] Kill near a teammate: teammate's points rise by half the kill reward; far teammate gets nothing
- [ ] Leader/Spartan has a team-colour glow and waypoint visible to allies, not to enemies
- [ ] Class picker, respawns and rounds behave as in Phase 3 (no first-person-Spartan fallback = no script fault)
