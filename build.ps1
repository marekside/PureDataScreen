#requires -Version 5
<#
.SYNOPSIS
  Build PureDataScreen for all supported Edge targets.

.DESCRIPTION
  Two build modes:
    prod  - default monkey.jungle + manifest.xml        -> bin\PureDataScreen-<device>.prg
    beta  - monkey-beta.jungle + manifest-beta.xml      -> bin\PureDataScreen-beta-<device>.prg

  Beta uses a separate application UUID and the "PureDataScreen (Beta)" name
  so it coexists with the production field on the same device.

.PARAMETER Mode
  "prod" or "beta". Defaults to "prod".

.EXAMPLE
  .\build.ps1                       # production build for all devices
  .\build.ps1 -Mode beta            # beta build for all devices
  .\build.ps1 -Mode beta -Device edge850   # single device
#>

param(
    [ValidateSet("prod", "beta")]
    [string]$Mode = "prod",

    [string]$Device = ""
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$sdkBin = "$env:APPDATA\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-9.2.0-2026-06-09-92a1605b2\bin"
if (-not (Test-Path -LiteralPath $sdkBin)) {
    throw "Connect IQ SDK not found at $sdkBin"
}

$jungle = if ($Mode -eq "beta") { "monkey-beta.jungle" } else { "monkey.jungle" }
$suffix = if ($Mode -eq "beta") { "beta" } else { $null }

$devices = if ($Device) {
    @($Device)
} else {
    @("edge540", "edge550", "edge840", "edge850", "edge1040", "edge1050")
}

if (-not (Test-Path -LiteralPath "bin")) {
    New-Item -ItemType Directory -Path "bin" | Out-Null
}

$failed = @()
foreach ($d in $devices) {
    $prgName = if ($suffix) { "PureDataScreen-$suffix-$d.prg" } else { "PureDataScreen-$d.prg" }
    $prgPath = Join-Path "bin" $prgName
    Write-Host "Building $d ($Mode) -> $prgPath" -ForegroundColor Cyan

    $args = @(
        "-d", $d
        "-f", $jungle
        "-o", $prgPath
        "-y", "developer_key"
        "-w"
    )

    & "$sdkBin\monkeyc.bat" @args
    if ($LASTEXITCODE -ne 0) {
        $failed += $d
    }
}

if ($failed.Count -gt 0) {
    Write-Host ""
    Write-Host "Build FAILED for: $($failed -join ', ')" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Build OK ($Mode) -> $($devices.Count) device(s)" -ForegroundColor Green
