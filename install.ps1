# Pasang konfigurasi Claude Code (agents, CLAUDE.md, model opusplan) di komputer ini.
$dest = Join-Path $env:USERPROFILE ".claude"
New-Item -ItemType Directory -Force -Path (Join-Path $dest "agents") | Out-Null

Copy-Item (Join-Path $PSScriptRoot "agents\*.md") (Join-Path $dest "agents") -Force

$claudeMd = Join-Path $dest "CLAUDE.md"
$src = Join-Path $PSScriptRoot "CLAUDE.md"
if (Test-Path $claudeMd) {
    Copy-Item $claudeMd "$claudeMd.bak" -Force
    Add-Content $claudeMd "`n"
    Get-Content $src | Add-Content $claudeMd
} else {
    Copy-Item $src $claudeMd
}

$settings = Join-Path $dest "settings.json"
if (Test-Path $settings) {
    Copy-Item $settings "$settings.bak" -Force
    $json = Get-Content $settings -Raw | ConvertFrom-Json
} else {
    $json = [pscustomobject]@{}
}
$json | Add-Member -NotePropertyName model -NotePropertyValue "opusplan" -Force
$json | ConvertTo-Json -Depth 20 | Set-Content $settings -Encoding utf8

Write-Host "Selesai. Tutup dan buka ulang Claude Code."
