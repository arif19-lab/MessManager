$f = 'C:\Users\Imran\mess_manager\lib\screens\home_screen.dart'
$lines = Get-Content $f -Encoding UTF8

# Show lines 249-256 to confirm which 'top:' to change
Write-Output "Lines 249-256 (circle Positioned):"
for ($i = 248; $i -lt 256; $i++) {
    Write-Output "$($i+1): '$($lines[$i])'"
}

# Line 253 (index 252) should be: "                    top: 0,"
# Change it to push circle lower — top: 18 means circle sits 18px below Stack top,
# and bar starts at overhang=10, so circle is 8px inside the bar top,
# notch depth is 26px so it still fits comfortably
$lines[252] = '                    top: 18,'

[System.IO.File]::WriteAllLines($f, $lines, [System.Text.Encoding]::UTF8)

$check = Get-Content $f -Encoding UTF8
Write-Output "`nAfter edit line 253: '$($check[252])'"
Write-Output "Done."
