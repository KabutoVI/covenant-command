# TACTICAL Covenant vs UNSC

Fork of Project Reclaimer's UNSC vs Covenant mode that aims to make the Covenant fun to play (squads, bigger reinforcement pool, earned vehicles). Full design: [ARCHITECTURE.md](ARCHITECTURE.md). History: [CHANGELOG.md](CHANGELOG.md).

## Status: early prototype

**UNSC-side work has not started.** So far this mode only changes the Covenant side (reinforcement pool and income, a Jackal Major class, a free Grunt Heavy) plus two small cohesion features that apply to both teams (shared kill points, ally waypoints). The UNSC roster, costs and economy are unchanged from upstream.

- The mode compiles and loads; only solo checks have been done, no full-lobby playtest yet.
- Squad respawn-on-leader did not work in solo tests and is off by default.
- Call-in vehicles are not started.

## Build

1. Copy `local.config.example` to `local.config` and set the client path.
2. `src\` already holds the forked script and template. To compare against a newer Project Reclaimer release, run `scripts\update-upstream.ps1` to fetch the upstream files into `upstream\`.
3. `scripts\build.ps1`, then `scripts\deploy-local.ps1` (headless local server on Guardian).
4. In a second window run `scripts\play.ps1` to open the client and join from the Server Browser. Log results in `docs\playtest-log.md`.

## Notes

- Distribute only our own source; game files and the Project Reclaimer client are not part of this repo.
- Mark every edit to upstream logic with a `-- CC:` comment.
- Pinned Project Reclaimer version: see `upstream\VERSION.txt` (0.9.23; the local exe filename still says v0.9.18 but its metadata is 0.9.23).
