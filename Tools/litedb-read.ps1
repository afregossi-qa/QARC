# LiteDB Smart Reader - Auto-detects and uses correct version
# Usage: .\litedb-read.ps1 <db-path> [collection] [limit]
#        .\litedb-read.ps1 <db-path> --list

param(
    [Parameter(Mandatory=$true)]
    [string]$DbPath,
    
    [string]$Collection = "--list",
    
    [int]$Limit = 100
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$v4Reader = Join-Path $scriptDir "LiteDbReader"
$v5Reader = Join-Path $scriptDir "LiteDbReader5"

if (-not (Test-Path $DbPath)) {
    Write-Error "Database file not found: $DbPath"
    exit 1
}

# Check header for version hint
$bytes = [System.IO.File]::ReadAllBytes($DbPath)[0..50]
$headerText = [System.Text.Encoding]::ASCII.GetString($bytes)
$hasV5Header = $headerText.Contains("This is a LiteDB file")

Write-Host "// File: $(Split-Path -Leaf $DbPath)"
Write-Host "// Header signature: $(if ($hasV5Header) { 'v5-style' } else { 'v4-style' })"
Write-Host ""

# Try v4 first (more common for POS files)
Write-Host "// Trying LiteDB v4..."
$result = & dotnet run --project $v4Reader -- $DbPath $Collection $Limit 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "// SUCCESS with v4 library"
    $result | Where-Object { $_ -notmatch "warning" }
    exit 0
}

# Try v5 if v4 failed
Write-Host "// v4 failed, trying LiteDB v5..."
$result = & dotnet run --project $v5Reader -- $DbPath $Collection $Limit 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "// SUCCESS with v5 library"
    $result | Where-Object { $_ -notmatch "warning" }
    exit 0
}

Write-Error "Could not read database with either v4 or v5 library"
exit 1
