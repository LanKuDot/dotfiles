@echo off
setlocal
set "HOOKSRC=%~dp0hook-notofication-settings.json"
set "SETTINGS=%USERPROFILE%\.claude\settings.json"

echo ============================================
echo  Claude Code notification hooks - installer
echo ============================================
echo.

if not exist "%HOOKSRC%" (
    echo [FAILED] Source file not found:
    echo          %HOOKSRC%
    goto :end_fail
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ErrorActionPreference = 'Stop';" ^
    "$src = Get-Content -Raw '%HOOKSRC%' | ConvertFrom-Json;" ^
    "$dir = Join-Path $env:USERPROFILE '.claude';" ^
    "if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null };" ^
    "$path = Join-Path $dir 'settings.json';" ^
    "if (Test-Path $path) { Copy-Item $path ($path + '.bak') -Force; $dst = Get-Content -Raw $path | ConvertFrom-Json } else { $dst = [pscustomobject]@{} };" ^
    "if (-not $dst.PSObject.Properties['hooks']) { $dst | Add-Member -NotePropertyName hooks -NotePropertyValue ([pscustomobject]@{}) };" ^
    "foreach ($p in $src.hooks.PSObject.Properties) { $dst.hooks | Add-Member -NotePropertyName $p.Name -NotePropertyValue $p.Value -Force };" ^
    "$json = $dst | ConvertTo-Json -Depth 20;" ^
    "[IO.File]::WriteAllText($path, $json, (New-Object System.Text.UTF8Encoding $false));" ^
    "Write-Host 'Installed hooks:';" ^
    "foreach ($p in $src.hooks.PSObject.Properties) { Write-Host ('  - ' + $p.Name) }"

if errorlevel 1 (
    echo.
    echo [FAILED] Could not update %SETTINGS%
    goto :end_fail
)

echo.
echo [SUCCESS] Settings written to:
echo           %SETTINGS%
if exist "%SETTINGS%.bak" echo           Backup saved as settings.json.bak
echo.
echo Hooks take effect in new Claude Code sessions.
echo.
pause
endlocal
exit /b 0

:end_fail
echo.
pause
endlocal
exit /b 1
