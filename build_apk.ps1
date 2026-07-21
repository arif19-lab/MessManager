$yaml = Get-Content "pubspec.yaml" -Raw
$match = [regex]::Match($yaml, 'version: ([\d\.]+)\+(\d+)')
$oldName = $match.Groups[1].Value
$oldCode = [int]$match.Groups[2].Value

$newCode = $oldCode + 1
$newYaml = $yaml -replace 'version: ([\d\.]+)\+(\d+)', "version: $oldName+$newCode"
Set-Content "pubspec.yaml" -Value $newYaml

Write-Host "Building APK (version $oldName+$newCode)..."
$env:CMAKE_POLICY_VERSION_MINIMUM="3.5"
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot"
flutter build apk --release
