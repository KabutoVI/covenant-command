# Start a local headless server running the compiled mode. Join it from the client's Server Browser
# (use scripts\play.ps1 to open it).
param([string]$ClientExe, [string]$MccPath, [int]$Seconds)
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
$serverArgs = @('local-server', '--mcc-path', $MccPath, '--variant', $mode)
if ($Seconds) { $serverArgs += @('--seconds', $Seconds) }
& $ClientExe @serverArgs
