# TACTICAL Covenant vs UNSC

Fork of Project Reclaimer's UNSC vs Covenant mode that makes the Covenant fun to play (squads, bigger reinforcement pool, earned vehicles). Full design: [ARCHITECTURE.md](ARCHITECTURE.md).

Status: Phase 1 (Setup). Scaffold only; no script yet.

## Build

1. Copy `local.config.example` to `local.config` and set the client path.
2. `scripts\update-upstream.ps1` to fetch the upstream files into `upstream\`, then copy them to `src\` as `covenant-command.rvt` / `template.json`.
3. `scripts\build.ps1`, then `scripts\deploy-local.ps1` (headless local server on Guardian).
4. In a second window run `scripts\play.ps1` to open the client and join from the Server Browser. Log results in `docs\playtest-log.md`.

## Notes

- Distribute only our own source; game files and the Project Reclaimer client are not part of this repo.
- Mark every edit to upstream logic with a `-- CC:` comment.
- Pinned Project Reclaimer version: see `upstream\VERSION.txt` (0.9.23; the local exe filename still says v0.9.18 but its metadata is 0.9.23).
