# Pasang konfigurasi Claude Code (agents, hook auto-routing, CLAUDE.md, model opusplan) di komputer ini.
$dest = Join-Path $env:USERPROFILE ".claude"
New-Item -ItemType Directory -Force -Path (Join-Path $dest "agents") | Out-Null

Copy-Item (Join-Path $PSScriptRoot "agents\*.md") (Join-Path $dest "agents") -Force
New-Item -ItemType Directory -Force -Path (Join-Path $dest "hooks") | Out-Null
Copy-Item (Join-Path $PSScriptRoot "hooks\*.js") (Join-Path $dest "hooks") -Force

$claudeMd = Join-Path $dest "CLAUDE.md"
$src = Join-Path $PSScriptRoot "CLAUDE.md"
if (Test-Path $claudeMd) {
    Copy-Item $claudeMd "$claudeMd.bak" -Force
    if ((Get-Content $claudeMd -Raw) -notmatch "# Task routing") {
        Add-Content $claudeMd "`n"
        Get-Content $src | Add-Content $claudeMd
    }
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

# Daftarkan hook auto-routing (hanya jika belum ada). Butuh Node.js terpasang.
$hookCmd = "node `"" + ($dest -replace "\\","/") + "/hooks/route-task.js`""
if (-not ($json.PSObject.Properties.Name -contains "hooks")) {
    $json | Add-Member -NotePropertyName hooks -NotePropertyValue ([pscustomobject]@{}) -Force
}
if (-not ($json.hooks.PSObject.Properties.Name -contains "UserPromptSubmit")) {
    $json.hooks | Add-Member -NotePropertyName UserPromptSubmit -NotePropertyValue @() -Force
}
if ((ConvertTo-Json $json.hooks.UserPromptSubmit -Depth 10) -notmatch "route-task.js") {
    $entry = [pscustomobject]@{ hooks = @([pscustomobject]@{ type = "command"; command = $hookCmd }) }
    $json.hooks.UserPromptSubmit = @($json.hooks.UserPromptSubmit) + $entry
}
[System.IO.File]::WriteAllText($settings, ($json | ConvertTo-Json -Depth 20), (New-Object System.Text.UTF8Encoding $false))

Write-Host "Selesai. Tutup dan buka ulang Claude Code."
