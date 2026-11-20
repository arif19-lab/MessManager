@echo off
title Auto ADB Wireless Connect
color 0A
echo ========================================================
echo        Mess Manager - Auto ADB Wireless Connect         
echo ========================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference = 'SilentlyContinue'; Write-Host 'Scanning for Android device on Wi-Fi...' -ForegroundColor Cyan; $connected = $false; $devices = adb devices; if ($devices -match '192\.168\.\d+\.\d+:\d+\s+device') { Write-Host 'Device is already connected!' -ForegroundColor Green; $connected = $true; }; if (-not $connected) { Write-Host 'Trying default port 5555...' -ForegroundColor Yellow; $res5555 = adb connect 192.168.1.104:5555; if ($res5555 -match 'connected to') { $connected = $true; Write-Host 'Connected via port 5555!' -ForegroundColor Green; } }; if (-not $connected) { Write-Host 'Searching via mDNS auto-discovery...' -ForegroundColor Yellow; for ($i = 1; $i -le 6; $i++) { $services = adb mdns services 2>$null; $match = [regex]::Match($services, '(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):(\d{4,5})'); if ($match.Success) { $endpoint = $match.Value; Write-Host \"Found device at $endpoint. Connecting...\" -ForegroundColor Cyan; $res = adb connect $endpoint; if ($res -match 'connected to') { $connected = $true; Write-Host \"Successfully connected to $endpoint!\" -ForegroundColor Green; break; } }; Start-Sleep -Seconds 1; } }; if ($connected) { Write-Host 'Priming fixed port 5555 for future reconnects...' -ForegroundColor DarkGray; adb tcpip 5555 | Out-Null; Write-Host ''; Write-Host '--------------------------------------------------------' -ForegroundColor Green; Write-Host ' [SUCCESS] Device is connected and ready for Flutter!' -ForegroundColor Green; Write-Host '--------------------------------------------------------' -ForegroundColor Green; adb devices -l; } else { Write-Host ''; Write-Host '--------------------------------------------------------' -ForegroundColor Red; Write-Host ' [FAILED] Could not find device on Wi-Fi.' -ForegroundColor Red; Write-Host ' Please ensure:' -ForegroundColor Yellow; Write-Host '  1. Phone and PC are on the same Wi-Fi.' -ForegroundColor Yellow; Write-Host '  2. Wireless Debugging is turned ON in Developer Options.' -ForegroundColor Yellow; Write-Host '--------------------------------------------------------' -ForegroundColor Red; };"

echo.
echo Press any key to exit...
pause >nul
