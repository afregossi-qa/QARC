<#
.SYNOPSIS
    Universal LiteDB Query Tool — automatically handles v4 and v5 databases.

.DESCRIPTION
    Tries LiteDB v5 reader first, then falls back to v4 if it fails.
    Seamless for the agent — no version detection needed.

.EXAMPLE
    .\litedb-query.ps1 "C:\path\to\file.db"                  # List collections
    .\litedb-query.ps1 "C:\path\to\file.db" -List            # List collections
    .\litedb-query.ps1 "C:\path\to\file.db" -Raw             # Raw binary extraction
    .\litedb-query.ps1 "C:\path\to\file.db" MenuHead         # Query all docs
    .\litedb-query.ps1 "C:\path\to\file.db" MenuHead 5       # Query 5 docs
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$DbPath,

    [Parameter(Position=1)]
    [string]$Collection,

    [Parameter(Position=2)]
    [int]$Limit = 100,

    [switch]$List,
    [switch]$Raw
)

# Tool paths (prefer Release, fallback to Debug)
$v5Exe = Join-Path $PSScriptRoot "v5\bin\Release\net6.0\LiteDbReader5.exe"
$v4Exe = Join-Path $PSScriptRoot "v4\bin\Release\net6.0\LiteDbReader.exe"
if (!(Test-Path $v5Exe)) { $v5Exe = Join-Path $PSScriptRoot "v5\bin\Debug\net6.0\LiteDbReader5.exe" }
if (!(Test-Path $v4Exe)) { $v4Exe = Join-Path $PSScriptRoot "v4\bin\Debug\net6.0\LiteDbReader.exe" }

# Validate
if (!(Test-Path $DbPath)) { Write-Error "File not found: $DbPath"; exit 1 }
if (!(Test-Path $v5Exe)) { Write-Error "LiteDbReader5 not found. Run: dotnet build Tools/LiteDBAnalyser/v5 -c Release"; exit 1 }
if (!(Test-Path $v4Exe)) { Write-Error "LiteDbReader not found. Run: dotnet build Tools/LiteDBAnalyser/v4 -c Release"; exit 1 }

# Build argument list for the exe readers
$readerArgs = @($DbPath)
if ($Raw) {
    $readerArgs += "--raw"
} elseif ($List -or [string]::IsNullOrEmpty($Collection)) {
    $readerArgs += "--list"
} else {
    $readerArgs += $Collection
    $readerArgs += $Limit.ToString()
}

# --- Try v4 first (most POS files are v4, v5 was pulled back. We should keep the v5 code for any remaining dependencies or future migration. ---
Write-Host "// Attempting LiteDB v4 reader..." -ForegroundColor DarkGray
$prevEA = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"
$v4Output = & $v4Exe @readerArgs 2>&1
$v4Exit = $LASTEXITCODE
$ErrorActionPreference = $prevEA

if ($v4Exit -eq 0) {
    $v4Output | ForEach-Object {
        if ($_ -is [System.Management.Automation.ErrorRecord]) { return }
        Write-Output $_
    }
    exit 0
}

# --- v4 failed → try v5 ---
Write-Host "// v4 failed, trying LiteDB v5 reader..." -ForegroundColor Yellow
$ErrorActionPreference = "SilentlyContinue"
$v5Output = & $v5Exe @readerArgs 2>&1
$v5Exit = $LASTEXITCODE
$ErrorActionPreference = $prevEA

# Detect failure: non-zero exit, raw fallback triggered, or DETECTED STRINGS (means structured read failed)
$v5Str = ($v5Output | Out-String)
$v5Failed = ($v5Exit -ne 0) -or `
            ($v5Str -match "All LiteDB connection strategies failed") -or `
            ($v5Str -match "Falling back to raw binary") -or `
            ($v5Str -match "DETECTED STRINGS")

if (-not $v5Failed) {
    $v5Output | ForEach-Object {
        if ($_ -is [System.Management.Automation.ErrorRecord]) { return }
        Write-Output $_
    }
    exit 0
}

# --- Both failed → raw extraction as last resort ---
Write-Host "// Both readers failed. Raw extraction..." -ForegroundColor Red
$ErrorActionPreference = "SilentlyContinue"
& $v5Exe $DbPath "--raw"
exit $LASTEXITCODE
