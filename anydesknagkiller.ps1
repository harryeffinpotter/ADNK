$ErrorActionPreference = 'SilentlyContinue'

# Disable QuickEdit so an accidental text-selection click can't freeze the script
try {
    Add-Type 'using System;using System.Runtime.InteropServices;public class QE{[DllImport("kernel32.dll")]public static extern IntPtr GetStdHandle(int h);[DllImport("kernel32.dll")]public static extern bool GetConsoleMode(IntPtr h,out uint m);[DllImport("kernel32.dll")]public static extern bool SetConsoleMode(IntPtr h,uint m);}'
    $h = [QE]::GetStdHandle(-10)
    $m = 0
    [void][QE]::GetConsoleMode($h, [ref]$m)
    [void][QE]::SetConsoleMode($h, ($m -band (-bnot 0x0040)) -bor 0x0080)
} catch {}

$e = [char]27
$r = "$e[0m"
$bold = "$e[1m"

# Force a very dark blue console background (OSC 11), then repaint the whole buffer
Write-Host "$e]11;rgb:08/08/1a$e\" -NoNewline
[Console]::Clear()

# Pastel rainbow colors (same 24 as PCGR)
$colors = @(
    "$e[38;2;255;182;193m", "$e[38;2;255;190;180m", "$e[38;2;255;200;170m",
    "$e[38;2;255;210;160m", "$e[38;2;255;220;150m", "$e[38;2;255;235;145m",
    "$e[38;2;255;250;150m", "$e[38;2;240;255;155m", "$e[38;2;220;255;165m",
    "$e[38;2;200;255;180m", "$e[38;2;180;255;195m", "$e[38;2;165;255;210m",
    "$e[38;2;155;255;230m", "$e[38;2;155;250;245m", "$e[38;2;160;240;255m",
    "$e[38;2;170;225;255m", "$e[38;2;180;210;255m", "$e[38;2;190;200;255m",
    "$e[38;2;200;195;255m", "$e[38;2;210;190;255m", "$e[38;2;220;188;255m",
    "$e[38;2;230;185;255m", "$e[38;2;240;185;250m", "$e[38;2;250;183;240m"
)

$colorEnabled  = "$e[38;2;180;240;255m"  # Bright near-white sky blue
$colorDisabled = "$e[38;2;220;20;60m"    # Bright crimson

function Write-Rainbow([string]$text, [int]$off = 0) {
    $out = ""
    for ($i = 0; $i -lt $text.Length; $i++) {
        $ci = ($i + $off) % 24
        if ($ci -lt 0) { $ci += 24 }
        $out += $colors[$ci] + $text[$i]
    }
    return "$out$r"
}

function Write-RainbowSep([int]$off = 0) {
    $out = ""
    for ($i = 0; $i -lt 41; $i++) {
        $ci = ($i + $off) % 24
        if ($ci -lt 0) { $ci += 24 }
        $out += $colors[$ci] + "="
    }
    return "$out$r"
}

$banner = @(
    ' █████╗  ██████╗  ███╗   ██╗ ██╗  ██╗',
    '██╔══██╗ ██╔══██╗ ████╗  ██║ ██║ ██╔╝',
    '███████║ ██║  ██║ ██╔██╗ ██║ █████╔╝ ',
    '██╔══██║ ██║  ██║ ██║╚██╗██║ ██╔═██╗ ',
    '██║  ██║ ██████╔╝ ██║ ╚████║ ██║  ██╗',
    '╚═╝  ╚═╝ ╚═════╝  ╚═╝  ╚═══╝ ╚═╝  ╚═╝'
)

function Draw-Frame([int]$top, [int]$frame, [bool]$showSep) {
    [Console]::SetCursorPosition(0, $top)
    $ln = $frame
    foreach ($row in $banner) {
        Write-Host "  $(Write-Rainbow $row $ln)"
        $ln++
    }
    [Console]::SetCursorPosition(0, $top + 7)
    Write-Host "$bold$(Write-Rainbow '   A N Y D E S K   N A G   K I L L E R' ($frame + 6))"
    if ($showSep) {
        [Console]::SetCursorPosition(0, $top + 8)
        Write-Host (Write-RainbowSep $frame)
    }
}

Write-Host ""
[Console]::CursorVisible = $false
$headerTop = [Console]::CursorTop

# Phases reveal exactly 1.5s apart, timed off a real stopwatch
$PHASE2 = 3  # separator + what-it-does message
$PHASE3 = 6.0  # warning
$PHASE4 = 9.0  # pause prompt

$msgShown = $false
$warnShown = $false
$promptShown = $false
$nextRow = $headerTop + 9
$bottom = $nextRow
$frame = 0
$sw = [System.Diagnostics.Stopwatch]::StartNew()

while ($true) {
    $t = $sw.Elapsed.TotalSeconds
    Draw-Frame $headerTop $frame ($t -ge $PHASE2)

    if ($t -ge $PHASE2 -and -not $msgShown) {
        [Console]::SetCursorPosition(0, $nextRow)
        Write-Host ""
        Write-Host "$colorEnabled${bold}ADNK$r Kills that annoying ~120-second nag screen that AnyDesk"
        Write-Host "starts popping up once you use it regularly - even if you've"
		Write-Host "only ever used the stupid fucking app on 2 machines. SMH."
        $nextRow = [Console]::CursorTop
        $msgShown = $true
    }
    if ($t -ge $PHASE3 -and -not $warnShown) {
        [Console]::SetCursorPosition(0, $nextRow)
        Write-Host ""
        Write-Host "$colorDisabled${bold}WARNING:$r This will remove all stored unattended access passwords + your address book."
        Write-Host "Be sure you know those (or have your address book backed up) before continuing."
        Write-Host "Local machines are automatically rediscovered - just re-enter the passwords."
        $nextRow = [Console]::CursorTop
        $warnShown = $true
    }
    if ($t -ge $PHASE4 -and -not $promptShown) {
        [Console]::SetCursorPosition(0, $nextRow)
        Write-Host ""
        Write-Host "$colorEnabled${bold}Press any key to continue$r, or $colorDisabled${bold}CTRL+C$r to bail if you don't have your passwords ready."
        $bottom = [Console]::CursorTop
        $promptShown = $true
    }

    if ($promptShown -and [Console]::KeyAvailable) { break }
    $frame++
    Start-Sleep -Milliseconds 200
}
[void][Console]::ReadKey($true)
[Console]::CursorVisible = $true
[Console]::SetCursorPosition(0, $bottom)
Write-Host ""

Write-Host "$colorEnabled-->$r Killing AnyDesk process..."
Stop-Process -Name AnyDesk -Force

$anyDeskData = Join-Path $env:ProgramData 'AnyDesk'
Write-Host "$colorEnabled-->$r Deleting service* and system* files from $anyDeskData..."
Remove-Item -Path (Join-Path $anyDeskData 'service*'), (Join-Path $anyDeskData 'system*') -Force

$anyDeskExe = "C:\Program Files (x86)\AnyDesk\AnyDesk.exe"
Write-Host "$colorEnabled-->$r Starting AnyDesk..."
Start-Process -FilePath $anyDeskExe

Write-Host ""
Write-Host (Write-Rainbow "Done.")
Pause
