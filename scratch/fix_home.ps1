$lines = Get-Content "C:\Users\Imran\mess_manager\lib\screens\home_screen.dart" -Encoding UTF8
$part1 = $lines[0..515]
$part2 = $lines[711..($lines.Count - 1)]
$newLines = $part1 + $part2
$newLines | Set-Content "C:\Users\Imran\mess_manager\lib\screens\home_screen.dart" -Encoding UTF8
Write-Host "Fixed file saved successfully!"
