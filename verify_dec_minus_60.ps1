param(
    [string] $Port = "COM35",
    [int] $Baud = 9600,
    [double] $TargetDec = -60.0,
    [double] $Tolerance = 0.5,
    [int] $SlewSettleMs = 8000,
    [int] $ReconnectDelayMs = 6000
)

$ErrorActionPreference = 'Stop'

function Stop-StalePlink {
    try { Get-Process plink -ErrorAction Stop | Stop-Process -Force } catch { }
}

function Invoke-Plink {
    param(
        [string[]] $Commands
    )
    $payload = ($Commands -join "`r`n") + "`r`n"
    return ($payload | & plink -batch -serial $Port -sercfg "$Baud,8,n,1,N")
}

function Parse-DecToDegrees {
    param([string] $s)
    # Expected like +DD*MM:SS or +DD:MM:SS; be permissive
    $rx = [regex] '([+\-]?)(\d{1,3})[\*:](\d{1,2}):(\d{1,2})'
    $m = $rx.Match($s)
    if (-not $m.Success) { throw "Unable to parse Dec from '$s'" }
    $sign = if ($m.Groups[1].Value -eq '-') { -1 } else { 1 }
    $dd = [double]$m.Groups[2].Value
    $mm = [double]$m.Groups[3].Value
    $ss = [double]$m.Groups[4].Value
    return $sign * ($dd + ($mm/60.0) + ($ss/3600.0))
}

function Get-DecDegrees {
    $out = Invoke-Plink @(':GD#')
    # Take the last non-empty line
    $line = ($out | Where-Object { $_ -and $_.Trim().Length -gt 0 } | Select-Object -Last 1).Trim()
    return Parse-DecToDegrees -s $line
}

function Assert-Near {
    param([double] $actual, [double] $expected, [double] $tol, [string] $label)
    $delta = [math]::Abs($actual - $expected)
    if ($delta -le $tol) {
        Write-Host "$label OK: $actual within ±$tol of $expected"
    } else {
        throw "$label FAIL: $actual not within ±$tol of $expected (Δ=$delta)"
    }
}

try {
    Write-Host "Closing any stale plink sessions..."
    Stop-StalePlink

    Write-Host "Verifying connectivity (:GU#)..."
    [void](Invoke-Plink @(':GU#'))

    Write-Host "Commanding slew to Dec $TargetDec..."
    [void](Invoke-Plink @(':ST1#', (':Sd{0:#00}:{1:00}:{2:00}#' -f [math]::Truncate([math]::Abs($TargetDec)) * [math]::Sign($TargetDec), 0, 0).Replace('#00','{0:00}'), ':MS#'))

    Start-Sleep -Milliseconds $SlewSettleMs

    $dec1 = Get-DecDegrees
    Assert-Near -actual $dec1 -expected $TargetDec -tol $Tolerance -label 'After slew'

    Write-Host "Issuing soft reset (:hR#) to test RTC persistence..."
    try { [void](Invoke-Plink @(':hR#')) } catch { }

    Start-Sleep -Milliseconds $ReconnectDelayMs

    $dec2 = Get-DecDegrees
    Assert-Near -actual $dec2 -expected $TargetDec -tol $Tolerance -label 'After soft reset'

    Write-Host "SUCCESS: Position persisted across soft reset."
    exit 0
} catch {
    Write-Error $_
    exit 1
}

$port = New-Object System.IO.Ports.SerialPort('COM35', 9600)
$port.ReadTimeout = 5000
$port.WriteTimeout = 5000
$port.Open()

Write-Output "Connected to OnStep on COM35 at 9600 baud"
Write-Output "Verifying position at Dec -60..."

# Get current position
Write-Output "Getting current position..."
$port.WriteLine(":GR#")
Start-Sleep -Seconds 1
$currentRA = $port.ReadExisting()
Write-Output "Current RA: '$currentRA'"

$port.WriteLine(":GD#")
Start-Sleep -Seconds 1
$currentDec = $port.ReadExisting()
Write-Output "Current Dec: '$currentDec'"

# Verify we're at Dec -60 (should be close to -60*00:00)
Write-Output "Verifying Dec position is close to -60 degrees..."
if ($currentDec -like "*-60*") {
    Write-Output "✅ CONFIRMED: Mount is at Dec -60 degrees"
} else {
    Write-Output "⚠️  WARNING: Mount is NOT at Dec -60 degrees"
    Write-Output "Expected: -60*00:00, Got: '$currentDec'"
}

# Record the exact position before reset
Write-Output "Recording position before soft reset..."
$port.WriteLine(":GR#")
Start-Sleep -Seconds 1
$raBefore = $port.ReadExisting()
Write-Output "RA before reset: '$raBefore'"

$port.WriteLine(":GD#")
Start-Sleep -Seconds 1
$decBefore = $port.ReadExisting()
Write-Output "Dec before reset: '$decBefore'"

# Perform soft reset
Write-Output "Performing soft reset..."
$port.WriteLine(":hR#")
Start-Sleep -Seconds 5

# Get position after reset
Write-Output "Getting position after soft reset..."
$port.WriteLine(":GR#")
Start-Sleep -Seconds 1
$raAfter = $port.ReadExisting()
Write-Output "RA after reset: '$raAfter'"

$port.WriteLine(":GD#")
Start-Sleep -Seconds 1
$decAfter = $port.ReadExisting()
Write-Output "Dec after reset: '$decAfter'"

# Compare positions
Write-Output "Comparing positions..."
Write-Output "RA before: '$raBefore'"
Write-Output "RA after:  '$raAfter'"
Write-Output "Dec before: '$decBefore'"
Write-Output "Dec after:  '$decAfter'"

# Check if positions are similar (allowing for small tracking differences)
if ($raBefore -eq $raAfter -and $decBefore -eq $decAfter) {
    Write-Output "✅ SUCCESS: Position held exactly after soft reset!"
} else {
    Write-Output "📊 Position comparison:"
    Write-Output "   RA change: '$raBefore' → '$raAfter'"
    Write-Output "   Dec change: '$decBefore' → '$decAfter'"
    
    # Check if Dec is still around -60
    if ($decAfter -like "*-60*") {
        Write-Output "✅ SUCCESS: Dec position maintained at -60 degrees"
    } else {
        Write-Output "❌ FAILURE: Dec position lost - no longer at -60 degrees"
    }
}

$port.Close()
Write-Output "Dec -60 verification test complete"

