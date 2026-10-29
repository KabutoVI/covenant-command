# Compile src\covenant-command.rvt + src\template.json into build\covenant-command.json.
# mode-compile never overwrites, so any previous output is moved to a timestamped name first.
param(
    [string]$ClientExe,
    [string]$Name = 'TACTICAL Covenant vs UNSC',
    [switch]$SquadDebug,
    [int]$AnchorType = 0
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent

if (-not $ClientExe) {
    $cfg = Join-Path $root 'local.config'
    if (-not (Test-Path $cfg)) { throw 'Pass -ClientExe or create local.config (see local.config.example).' }
    $c = Get-Content $cfg | Where-Object { $_ -match '^\s*[^#].*=' } |
        ForEach-Object { $k,$v = $_ -split '=',2; @{ $k.Trim() = $v.Trim() } }
    $h = @{}; $c | ForEach-Object { $_.GetEnumerator() | ForEach-Object { $h[$_.Key] = $_.Value } }
    $ClientExe = Join-Path $h.ClientDir $h.ClientExe
}

$src = Join-Path $root 'src\covenant-command.rvt'
$tpl = Join-Path $root 'src\template.json'
if ($SquadDebug) {
    # Solo testing: default squad_debug to 1 in a throwaway copy of the template.
    $tmp = Join-Path $root 'build\template.debug.json'
    (Get-Content $tpl -Raw) -replace '(?s)(\"squad_debug\": \{\s*\"value\": )0','${1}1' -replace '(?s)(\"squad_type\": \{\s*\"value\": )0',('${1}' + $AnchorType) | Set-Content $tmp
    $tpl = $tmp
}
$out = Join-Path $root 'build\covenant-command.json'

if (Test-Path $out) {
    $stamp = (Get-Item $out).LastWriteTime.ToString('yyyyMMdd-HHmmss')
    Move-Item $out (Join-Path $root "build\covenant-command-$stamp.json")
}

& $ClientExe megalo-check $src
if ($LASTEXITCODE) { throw 'megalo-check failed' }
& $ClientExe mode-compile $src --template $tpl --output $out --name $Name
if ($LASTEXITCODE) { throw 'mode-compile failed' }
& $ClientExe mode-check $out
if ($LASTEXITCODE) { throw 'mode-check failed' }
Write-Host "Built $out"


