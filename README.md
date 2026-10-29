# TACTICAL Covenant vs UNSC

A game mode for [Project Reclaimer](https://projectreclaimer.dev/), the modding client for Halo: The Master Chief Collection. It is a fork of Project Reclaimer's UNSC vs Covenant mode that tries to make the Covenant more fun to play: squads, a bigger reinforcement pool and earned vehicles. Full design: [ARCHITECTURE.md](ARCHITECTURE.md). History: [CHANGELOG.md](CHANGELOG.md).

## Status: early prototype

**UNSC-side work has not started.** So far the mode only changes the Covenant side (reinforcement pool and income, a Jackal Major class, a free Grunt Heavy) plus two small features that apply to both teams (shared kill points and ally waypoints). The UNSC roster, costs and economy are unchanged from upstream.

- The mode compiles and loads. Only solo checks have been done, with no full-lobby playtest yet.
- Squad respawn on the leader did not work in solo tests and is off by default.
- Call-in vehicles are not started.

## What you need

- Your own copy of Halo: The Master Chief Collection, with Halo 3 campaign installed.
- Your own copy of the Project Reclaimer client. This repo does not include the game, the client or any of their files.
- Windows and PowerShell.

The mode is developed against Project Reclaimer 0.9.23. Players need the same Project Reclaimer version as the server.

## Build

1. Copy `local.config.example` to `local.config` and set `ClientDir` and `ClientExe` to your Project Reclaimer client. Set `GameModesDir` if you want to use the Avalanche test playlist.
2. Run `scripts\build.ps1`. It checks and compiles `src\covenant-command.rvt` with `src\template.json` into `build\covenant-command.json`.
3. Run `scripts\deploy-local.ps1` to start a local server with the mode. By default it copies the built mode into `GameModesDir` and uses the Avalanche test playlist. With `-Guardian` it runs the mode on its own instead.
4. In a second window run `scripts\play.ps1` to open the client, then join from the Server Browser.

Log results in `docs\playtest-log.md`.

## Upstream files

The mode in `src\` started as a copy of Project Reclaimer's UNSC vs Covenant mode, and edits to its logic are marked with `-- CC:` comments. The original files are not stored in this repo. To compare against the current upstream versions, run `scripts\update-upstream.ps1`, which downloads them into `upstream\` (ignored by git).

## License

The files I wrote are under the [MIT License](LICENSE). The mode in `src\` builds on Project Reclaimer's UNSC vs Covenant mode, which has its own terms. See Project Reclaimer for those.
