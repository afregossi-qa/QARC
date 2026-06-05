---
description: Core folder structure and suffix conventions for the QA pipeline
inclusion: auto
---

# Project Structure — Core

## Ticket Folder Layout

```
{TICKET_ID} - {description}/
├── 1_Expert/       # logic_explanation, test_plan, manual_input
├── 2_Validator/    # FINAL_TEST_CASES, CSV export, TC coverage summary
├── 3_Evidence/     # Raw data ONLY (JSON, PNG, JPG)
├── 4_Reviewer/     # EXECUTION_FINDINGS, FINAL_CLOSURE_REPORT
├── 5_Snapshots/    # Auto-backups before overwrites
└── 6_Automation/   # Test scripts and logs (optional)
```

Tickets live in `{year}/Q{N}/Version {V}/`. The `{TICKET_ID}` is the full Jira key (e.g., `POS-9967`, `ACV2-642`, `QUPOS-123`). Hooks use `**` globs — depth doesn't matter.

## Suffix Convention

| Suffix | Meaning | Triggers |
|--------|---------|----------|
| `_PENDING` | Agent draft, awaiting review | Nothing |
| `_OK` | Human approved | Next stage |
| `_UPDATED` | Human feedback added | Revision hook |
| `_API` | AIO sync requested | AIO push |
| `_CSV` | Export requested | CSV export |
| `_VALIDATED` | Closure approved (STABLE) | Dashboard |
| `_REMEDIATE` | UNSTABLE, needs rework | Remediation |

## Ticket Root Files

Allowed at ticket root: `.state.json`, `AIO_SYNC_LOG.md`, `REMEDIATION_LOG.md`, `LESSONS_LEARNED.md`, `QA_DASHBOARD.md`, `SUMMARY.md`, `*_ERROR.md`, `Automation_Blueprint*.md`

For full naming rules, file placement details, and test case organization: read `@structure-details.md`
