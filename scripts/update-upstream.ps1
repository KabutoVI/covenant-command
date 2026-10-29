# Download the current upstream UNSC vs Covenant files into upstream\ for diffing against src\.
# Run only when you want to refresh; record the Project Reclaimer version in upstream\VERSION.txt afterwards.
# NOTE: the .rvt may be served as binary; Invoke-WebRequest -OutFile saves it byte-for-byte.
$ErrorActionPreference = 'Stop'
$up = Join-Path (Split-Path $PSScriptRoot -Parent) 'upstream'
$base = 'https://projectreclaimer.dev/modes'
foreach ($f in 'faction-battlefront-template.json','megalo-faction-battlefront.rvt') {
    Invoke-WebRequest "$base/$f" -OutFile (Join-Path $up $f)
}
Get-ChildItem $up | Select-Object Name, Length
