# =============================================
# Mess Manager - Professional Build Script
# =============================================

$ErrorActionPreference = "Continue"
$buildStartTime = Get-Date
$logFile = "build_log_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt"
$buildResults = @{}

function Write-Log {
    param([string]$Message, [string]$Color = "White")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage -ForegroundColor $Color
    Add-Content $logFile $logMessage
}

function Get-FileSize {
    param([string]$Path)
    if (Test-Path $Path) {
        $size = (Get-Item $Path).Length / 1MB
        return "$([math]::Round($size, 1)) MB"
    }
    return "N/A"
}

# ─── HEADER ───────────────────────────────────
Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║       MESS MANAGER BUILD SYSTEM      ║" -ForegroundColor Cyan
Write-Host "  ║        Professional Release Tool     ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ─── VERSION UPDATE ───────────────────────────
$pubspecPath = "pubspec.yaml"
$content = Get-Content $pubspecPath -Raw

if ($content -match 'version:\s*(\d+\.\d+\.\d+)\+(\d+)') {
    $versionName = $Matches[1]
    $versionCode = [int]$Matches[2]
    $newVersionCode = $versionCode + 1
    $newVersionLine = "version: $versionName+$newVersionCode"
    $content = $content -replace 'version:\s*\d+\.\d+\.\d+\+\d+', $newVersionLine
    Set-Content $pubspecPath $content
    Write-Log "Version: $versionName+$versionCode  →  $versionName+$newVersionCode" "Green"
} else {
    Write-Log "ERROR: Could not find version in pubspec.yaml" "Red"
    exit 1
}

Write-Host ""

# ─── PLATFORM SELECTION ───────────────────────
Write-Host "  Select platforms to build:" -ForegroundColor Yellow
Write-Host "  [1] All platforms (Android + Web + Windows)" -ForegroundColor White
Write-Host "  [2] Android only" -ForegroundColor White
Write-Host "  [3] Web only" -ForegroundColor White
Write-Host "  [4] Windows only" -ForegroundColor White
Write-Host "  [5] Android + Web" -ForegroundColor White
Write-Host ""
$platformChoice = Read-Host "  Enter choice (1-5)"

$buildAndroid = $false
$buildWeb = $false
$buildWindows = $false

switch ($platformChoice) {
    "1" { $buildAndroid = $true; $buildWeb = $true; $buildWindows = $true }
    "2" { $buildAndroid = $true }
    "3" { $buildWeb = $true }
    "4" { $buildWindows = $true }
    "5" { $buildAndroid = $true; $buildWeb = $true }
    default { 
        Write-Log "Invalid choice. Building all platforms." "Yellow"
        $buildAndroid = $true; $buildWeb = $true; $buildWindows = $true 
    }
}

Write-Host ""

# ─── CONFIRMATION ─────────────────────────────
$platforms = @()
if ($buildAndroid) { $platforms += "Android" }
if ($buildWeb) { $platforms += "Web" }
if ($buildWindows) { $platforms += "Windows" }

Write-Host "  Ready to build: $($platforms -join ' + ')" -ForegroundColor Cyan
Write-Host "  Version: $versionName+$newVersionCode" -ForegroundColor Cyan
Write-Host ""
$confirm = Read-Host "  Start build? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Log "Build cancelled by user." "Yellow"
    exit 0
}

Write-Host ""
Write-Log "Build started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" "Cyan"
Write-Host ""

# ─── SETUP ────────────────────────────────────
$env:CMAKE_POLICY_VERSION_MINIMUM = "3.5"
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot"

# ─── CLEAN ────────────────────────────────────
Write-Log "Cleaning project..." "Yellow"
flutter clean | Out-Null
flutter pub get | Out-Null
Write-Log "Clean complete." "Green"
Write-Host ""

# ─── ANDROID BUILD ────────────────────────────
if ($buildAndroid) {
    Write-Log "━━━ Building Android APK ━━━" "Cyan"
    $start = Get-Date
    flutter build apk --release
    $duration = [math]::Round(((Get-Date) - $start).TotalSeconds, 1)
    
    $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
    if ($LASTEXITCODE -eq 0 -and (Test-Path $apkPath)) {
        $size = Get-FileSize $apkPath
        Write-Log "✅ Android build SUCCESS! ($duration sec) | Size: $size" "Green"
        $buildResults["Android"] = "✅ SUCCESS ($size)"
    } else {
        Write-Log "❌ Android build FAILED! ($duration sec)" "Red"
        $buildResults["Android"] = "❌ FAILED"
    }
    Write-Host ""
}

# ─── WEB BUILD ────────────────────────────────
if ($buildWeb) {
    Write-Log "━━━ Building Web App ━━━" "Cyan"
    $start = Get-Date
    flutter build web
    $duration = [math]::Round(((Get-Date) - $start).TotalSeconds, 1)
    
    if ($LASTEXITCODE -eq 0) {
        Write-Log "✅ Web build SUCCESS! ($duration sec)" "Green"
        $buildResults["Web Build"] = "✅ SUCCESS"
        
        # Firebase Deploy
        Write-Log "Deploying to Firebase..." "Yellow"
        $start2 = Get-Date
        firebase deploy --only hosting --project mess-manager-6dcce
        $duration2 = [math]::Round(((Get-Date) - $start2).TotalSeconds, 1)
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "✅ Firebase deploy SUCCESS! ($duration2 sec)" "Green"
            Write-Log "   Live at: https://mess-manager-6dcce.web.app" "Green"
            $buildResults["Web Deploy"] = "✅ LIVE at https://mess-manager-6dcce.web.app"
        } else {
            Write-Log "❌ Firebase deploy FAILED!" "Red"
            $buildResults["Web Deploy"] = "❌ FAILED"
        }
    } else {
        Write-Log "❌ Web build FAILED! ($duration sec)" "Red"
        $buildResults["Web Build"] = "❌ FAILED"
    }
    Write-Host ""
}

# ─── WINDOWS BUILD ────────────────────────────
if ($buildWindows) {
    Write-Log "━━━ Building Windows App ━━━" "Cyan"
    $start = Get-Date
    flutter build windows
    $duration = [math]::Round(((Get-Date) - $start).TotalSeconds, 1)
    
    $exePath = "build\windows\x64\runner\Release\mess_manager.exe"
    if ($LASTEXITCODE -eq 0 -and (Test-Path $exePath)) {
        $size = Get-FileSize $exePath
        Write-Log "✅ Windows build SUCCESS! ($duration sec) | Size: $size" "Green"
        $buildResults["Windows"] = "✅ SUCCESS ($size)"
    } else {
        Write-Log "❌ Windows build FAILED! ($duration sec)" "Red"
        $buildResults["Windows"] = "❌ FAILED"
    }
    Write-Host ""
}

# ─── SUMMARY ──────────────────────────────────
$totalDuration = [math]::Round(((Get-Date) - $buildStartTime).TotalMinutes, 1)

Write-Host ""
Write-Host "  ╔══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║           BUILD SUMMARY              ║" -ForegroundColor Cyan
Write-Host "  ╠══════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "  ║  Version : $versionName+$newVersionCode" -ForegroundColor White
Write-Host "  ║  Duration: $totalDuration minutes" -ForegroundColor White
Write-Host "  ╠══════════════════════════════════════╣" -ForegroundColor Cyan

foreach ($key in $buildResults.Keys) {
    $result = $buildResults[$key]
    $color = if ($result -like "✅*") { "Green" } else { "Red" }
    Write-Host "  ║  $key : $result" -ForegroundColor $color
}

Write-Host "  ╠══════════════════════════════════════╣" -ForegroundColor Cyan

if ($buildAndroid -and (Test-Path "build\app\outputs\flutter-apk\app-release.apk")) {
    Write-Host "  ║  APK: build\app\outputs\flutter-apk\" -ForegroundColor Yellow
}
if ($buildWindows -and (Test-Path "build\windows\x64\runner\Release\")) {
    Write-Host "  ║  EXE: build\windows\x64\runner\Release\" -ForegroundColor Yellow
}

Write-Host "  ║  LOG: $logFile" -ForegroundColor Gray
Write-Host "  ╚══════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Log "Build finished at $(Get-Date -Format 'HH:mm:ss') | Total: $totalDuration min" "Cyan"