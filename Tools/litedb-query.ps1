# LiteDB Query Tool for QA Testing
# Usage: .\litedb-query.ps1 -DbPath "path\to\db.db" -Collection "Checks" [-Query "$.ProcessingState = 'Suspending'"] [-Limit 10]

param(
    [Parameter(Mandatory=$true)]
    [string]$DbPath,
    
    [Parameter(Mandatory=$true)]
    [string]$Collection,
    
    [string]$Query = "",
    
    [int]$Limit = 100,
    
    [string]$OutputFormat = "json"  # json or table
)

# Check if LiteDB.Shell is installed
$litedbShell = Get-Command "LiteDB.Shell" -ErrorAction SilentlyContinue

if (-not $litedbShell) {
    Write-Host "Installing LiteDB.Shell dotnet tool..." -ForegroundColor Yellow
    dotnet tool install --global LiteDB.Shell
}

# Verify DB file exists
if (-not (Test-Path $DbPath)) {
    Write-Error "Database file not found: $DbPath"
    exit 1
}

# Build the query command
if ($Query -eq "") {
    $litedbQuery = "SELECT $ FROM $Collection LIMIT $Limit"
} else {
    $litedbQuery = "SELECT $ FROM $Collection WHERE $Query LIMIT $Limit"
}

Write-Host "Executing: $litedbQuery" -ForegroundColor Cyan
Write-Host "Database: $DbPath" -ForegroundColor Cyan
Write-Host ""

# Execute query using LiteDB.Shell
try {
    $result = & LiteDB.Shell $DbPath --command "$litedbQuery" 2>&1
    
    if ($OutputFormat -eq "json") {
        $result | ConvertTo-Json -Depth 10
    } else {
        $result
    }
} catch {
    Write-Error "Failed to query LiteDB: $_"
    exit 1
}
