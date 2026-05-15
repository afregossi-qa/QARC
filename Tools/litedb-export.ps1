# LiteDB Export Tool - Export collection to JSON file
# Usage: .\litedb-export.ps1 -DbPath "path\to\db.db" -Collection "Checks" -OutputPath "output.json"

param(
    [Parameter(Mandatory=$true)]
    [string]$DbPath,
    
    [Parameter(Mandatory=$true)]
    [string]$Collection,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputPath,
    
    [string]$Query = "",
    
    [int]$Limit = 1000
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

Write-Host "Exporting: $litedbQuery" -ForegroundColor Cyan
Write-Host "Database: $DbPath" -ForegroundColor Cyan
Write-Host "Output: $OutputPath" -ForegroundColor Cyan
Write-Host ""

# Execute query and export to JSON
try {
    $result = & LiteDB.Shell $DbPath --command "$litedbQuery" 2>&1
    $result | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "Export complete: $OutputPath" -ForegroundColor Green
} catch {
    Write-Error "Failed to export LiteDB: $_"
    exit 1
}
