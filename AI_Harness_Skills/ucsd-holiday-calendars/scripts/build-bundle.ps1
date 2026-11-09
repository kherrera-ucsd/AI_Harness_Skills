param(
    [string]$OutputDir = (Join-Path $PSScriptRoot '..\dist')
)

$ErrorActionPreference = 'Stop'

$assetsDir = Join-Path $PSScriptRoot '..\assets'
$resolved = Resolve-Path -LiteralPath $OutputDir -ErrorAction SilentlyContinue
if ($resolved) { $OutputDir = $resolved.ProviderPath }
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

function Get-CalendarEvents([string]$Path) {
    $lines = [System.IO.File]::ReadAllLines($Path)
    $events = @()
    $inEvent = $false
    $current = $null
    foreach ($line in $lines) {
        if ($line -eq 'BEGIN:VEVENT') {
            $inEvent = $true
            $current = New-Object System.Collections.Generic.List[string]
            [void]$current.Add($line)
        } elseif ($line -eq 'END:VEVENT') {
            if ($inEvent) { [void]$current.Add($line); $events += (($current.ToArray() -join "`r`n")); $inEvent = $false; $current = $null }
        } elseif ($inEvent) {
            [void]$current.Add($line)
        }
    }
    return $events
}

$yearDirs = Get-ChildItem -LiteralPath $assetsDir -Directory | Sort-Object Name
if (-not $yearDirs) { throw "No year folders found under $assetsDir" }

$allEvents = @()
$yearFiles = @()

foreach ($yearDir in $yearDirs) {
    $icsFiles = Get-ChildItem -LiteralPath $yearDir.FullName -Filter '*.ics' | Sort-Object Name
    $yearEvents = @()
    foreach ($file in $icsFiles) { $yearEvents += Get-CalendarEvents $file.FullName }

    $yearStamp = [datetime]::UtcNow.ToString('yyyyMMddTHHmmssZ')
    $yearLines = @(
        'BEGIN:VCALENDAR'
        'VERSION:2.0'
        "PRODID:-//TritonAI//UCSD Holidays $($yearDir.Name)//EN"
        'CALSCALE:GREGORIAN'
    )
    foreach ($event in $yearEvents) { $yearLines += ($event -split "`r`n") }
    $yearLines += 'END:VCALENDAR'

    $yearFileName = "ucsd-holidays-$($yearDir.Name).ics"
    $yearPath = Join-Path $OutputDir $yearFileName
    [System.IO.File]::WriteAllLines($yearPath, $yearLines, (New-Object System.Text.UTF8Encoding($false)))
    $yearFiles += $yearPath
    $allEvents += $yearEvents
}

$allStamp = [datetime]::UtcNow.ToString('yyyyMMddTHHmmssZ')
$allLines = @(
    'BEGIN:VCALENDAR'
    'VERSION:2.0'
    'PRODID:-//TritonAI//UCSD Holidays All Years//EN'
    'CALSCALE:GREGORIAN'
)
foreach ($event in $allEvents) { $allLines += ($event -split "`r`n") }
$allLines += 'END:VCALENDAR'

$allPath = Join-Path $OutputDir 'ucsd-holidays-all.ics'
[System.IO.File]::WriteAllLines($allPath, $allLines, (New-Object System.Text.UTF8Encoding($false)))

$zipPath = Join-Path $OutputDir 'ucsd-holiday-calendars.zip'
if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
$staging = Join-Path $env:TEMP "ucsd-bundle-$([guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Path $staging | Out-Null
try {
    foreach ($yearDir in $yearDirs) {
        $yearDest = Join-Path $staging $yearDir.Name
        New-Item -ItemType Directory -Path $yearDest | Out-Null
        Copy-Item -Path (Join-Path $yearDir.FullName '*.ics') -Destination $yearDest
    }
    foreach ($file in $yearFiles) { Copy-Item -LiteralPath $file -Destination $staging }
    Copy-Item -LiteralPath $allPath -Destination $staging
    Compress-Archive -LiteralPath (Get-ChildItem $staging | ForEach-Object FullName) -DestinationPath $zipPath
} finally {
    Remove-Item -LiteralPath $staging -Recurse -Force
}

Write-Host "Combined calendar: $allPath ($($allEvents.Count) events)"
Write-Host "Per-year calendars: $($yearFiles -join ', ')"
Write-Host "Bundle ZIP: $zipPath"
