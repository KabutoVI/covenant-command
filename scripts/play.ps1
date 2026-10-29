# Open the Project Reclaimer game client menu (Server Browser) to join the local server.
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$h = @{}
Get-Content (Join-Path $root 'local.config') | Where-Object { $_ -match '^\s*[^#].*=' } | ForEach-Object { $k,$v = $_ -split '=',2; $h[$k.Trim()] = $v.Trim() }
& (Join-Path $h.ClientDir $h.ClientExe) game-client
