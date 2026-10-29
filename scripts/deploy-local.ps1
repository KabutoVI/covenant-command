# Start a local server running the compiled mode. Client then joins from the Server Browser.
param([string]$ClientExe)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
if (-not $ClientExe) {
    $cfg = Join-Path $root 'local.config'
    if (-not (Test-Path $cfg)) { throw 'Pass -ClientExe or create local.config.' }
    $h = @{}
    Get-Content $cfg | Where-Object { $_ -match '^\s*[^#].*=' } | ForEach-Object { $k,$v = $_ -split '=',2; $h[$k.Trim()] = $v.Trim() }
    $ClientExe = Join-Path $h.ClientDir $h.ClientExe
}
$mode = Join-Path $root 'build\covenant-command.json'
if (-not (Test-Path $mode)) { throw 'Run scripts\build.ps1 first.' }
& $ClientExe local-server --variant $mode
