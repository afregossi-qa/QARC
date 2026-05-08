---
inclusion: auto
description: LiteDB database reading capability for POS local database investigation
---

# LiteDB Database Reading Capability

## Token-Efficient Usage (CRITICAL)

**ALWAYS limit queries to minimize token consumption:**

```powershell
# GOOD: Limit to 1-3 documents for investigation
dotnet run --project Tools/LiteDbReader -- "path/to/file.db" DBCheck 1

# BAD: No limit = returns all documents (wastes tokens)
dotnet run --project Tools/LiteDbReader -- "path/to/file.db" DBCheck
```

**Extract specific fields using PowerShell filtering:**
```powershell
# Extract only key FO fields (minimal tokens)
dotnet run --project Tools/LiteDbReader -- "path.db" DBCheck 5 2>&1 | Select-String -Pattern '"CheckNumber"|"State"|"ProcessingState"|"IsOrderScheduled"'
```

## Quick Reference

| Action | Command |
|--------|---------|
| List collections | `dotnet run --project Tools/LiteDbReader -- "file.db" --list` |
| Query 1 doc | `dotnet run --project Tools/LiteDbReader -- "file.db" DBCheck 1` |
| Query with filter | `... DBCheck 3 \| Select-String "CheckNumber\|State"` |

## Key POS Fields

| Field | Purpose |
|-------|---------|
| `ProcessingState` | Legacy state (NOT updated by Order Scheduler) |
| `IsOrderScheduled` | `true` = Future Order |
| `OrderReadyDateTime` | FO ready time |
| `State` | "Open", "Suspended", "Closed" |

## Version Note

POS files use LiteDB v4 internally. If v4 fails, try `Tools/LiteDbReader5`.
