# Download the current upstream UNSC vs Covenant files from projectreclaimer.dev into upstream\ for diffing against src\.
# upstream\ is not part of this repo (it is gitignored); run this script to create it.
# Run only when you want to refresh, and note the Project Reclaimer version in the README afterwards.
# NOTE: the .rvt may be served as binary; Invoke-WebRequest -OutFile saves it byte-for-byte.
$ErrorActionPreference = 'Stop'
$up = Join-Path (Split-Path $PSScriptRoot -Parent) 'upstream'
New-Item -ItemType Directory -Force $up | Out-Null
$base = 'https://projectreclaimer.dev/modes'
foreach ($f in 'faction-battlefront-template.json','megalo-faction-battlefront.rvt') {
    Invoke-WebRequest "$base/$f" -OutFile (Join-Path $up $f)
}
Get-ChildItem $up | Select-Object Name, Length
