# Start a local headless server running the compiled mode. Join it from the client's Server Browser
# (use scripts\play.ps1 to open it).
param([string]$ClientExe, [string]$MccPath, [int]$Seconds, [switch]$Guardian)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$h = @{}
$cfg = Join-Path $root 'local.config'
if (Test-Path $cfg) {
    Get-Content $cfg | Where-Object { $_ -match '^\s*[^#].*=' } | ForEach-Object { $k,$v = $_ -split '=',2; $h[$k.Trim()] = $v.Trim() }
}
if (-not $MccPath)   { $MccPath = $h.ClientDir }
if (-not $ClientExe) { $ClientExe = Join-Path $h.ClientDir $h.ClientExe }
if (-not (Test-Path $ClientExe)) { throw 'Client exe not found; fix local.config.' }
$mode = Join-Path $root 'build\covenant-command.json'
if (-not (Test-Path $mode)) { throw 'Run scripts\build.ps1 first.' }
if ($Guardian) {
    $serverArgs = @('local-server', '--mcc-path', $MccPath, '--variant', $mode)
} else {
    # Avalanche (file name sidewinder): the playlist names the mode as a file in Game Modes.
    if (-not $h.GameModesDir) { throw 'Set GameModesDir in local.config.' }
    Copy-Item $mode (Join-Path $h.GameModesDir 'covenant-command.json') -Force
    $serverArgs = @('local-server', '--mcc-path', $MccPath, '--playlist', (Join-Path $root 'playlists\avalanche-test.playlist.json'))
}
if ($Seconds) { $serverArgs += @('--seconds', $Seconds) }
& $ClientExe @serverArgs

