# Skill: AIO-API-Mapper

Maps test case data from Markdown files to AIO Tests MCP server API calls.

## When to Use
Activate this skill when pushing test cases to AIO Tests via the `aio-tests` MCP server (create_case, update_case, create_cases_bulk).

## Project Configuration
- Project Key: `POS`
- API: `aio-tests` MCP server
- Script Type: Always `Classic`

## Field Mapping: Markdown → AIO API

| Markdown Field | AIO API Parameter | Notes |
|---|---|---|
| Test Case Title | `title` | Required. Format: `"POS-XXXX \| {Feature Brief} : {Test Case Title}"` (pipe after ticket, colon before TC title) |
| Description / Objective | `description` | Include test data section |
| Preconditions | `precondition` | Newline-separated, each line starts with `- ` |
| Priority (Critical/High/Medium) | `priority` | String: `"Critical"`, `"High"`, `"Medium"` |
| Automation Status | `automationStatus` | String: `"To Be Automated"`, `"Manual"`, `"Automated"` |
| Folder | `folderID` | Numeric ID — use `get_folders` to resolve name → ID |
| Test Steps | `steps` | Array of `{ step, expectedResult }` objects |
| Jira Ticket | `jiraTicket` | Only works on `create_case` (not guaranteed to persist) |
| Tags | `tags` | Only works on `create_case` (not guaranteed to persist) |
| AI-Generated | `customFields` | `[{"ID": 9, "value": "Yes"}]` — ALWAYS include on create/update. Use string `"Yes"` or `"No"`. |
| AI-Automated | `customFields` | `[{"ID": 8, "value": "No"}]` — `"Yes"` if 6_Automation/ has scripts, `"No"` otherwise. Use string `"Yes"` or `"No"`. |

## Custom Fields: AI-Generated & AI-Automated (Mandatory)

These two custom fields MUST be populated for every test case synced to AIO:

| Field | Value Logic | Default |
|-------|-------------|---------|
| **AI-Generated** | `"Yes"` if the test case was authored by the QA pipeline (Expert → Validator agents). `"No"` only if manually written by a human tester. | `"Yes"` (all pipeline TCs) |
| **AI-Automated** | `"Yes"` if the Automation Pipeline (Architect → Translator → Executor) has produced executable scripts in `6_Automation/`. `"No"` if no automation scripts exist yet. | `"No"` (until automation runs) |

### How to Populate
- **REST API (`create_case` / `update_case`)**: ALWAYS include `customFields` parameter with `[{"ID": 9, "value": "Yes"}, {"ID": 8, "value": "No"}]`. Values MUST be strings `"Yes"` or `"No"` (not booleans, not `"true"`/`"false"`, not `"1"`/`"0"`).
- **On create_case**: Include `customFields` in every create call. No separate update needed.
- **On update_case**: Include `customFields` only if values need changing.

### Determination Logic for AI-Automated
1. Check if `6_Automation/` folder exists in the ticket directory
2. If scripts (`.java`, `.py`) exist for the specific TC → `"Yes"`
3. If no scripts exist or `6_Automation/` is empty → `"No"`
4. If the local `Automation Status` tag is `Required` but no scripts exist yet → `"No"` (will become `"Yes"` after Translator/Executor run)

---

## Criteria Reference: Automation Status & Regression Tagging

> **Full criteria documented in:** `@regression-automation-criteria.md` (`.kiro/steering/regression-automation-criteria.md`)
> **Confluence source:** [QA Best Practices – Selecting Test Cases for Automation](https://qubeyond.atlassian.net/wiki/spaces/TE/pages/2405400590)

### Local Automation Status (Validator Tags — NOT sent to AIO)

The Validator assigns one of two values per TC. These stay in markdown only:

| Value | Criteria | Examples |
|-------|----------|----------|
| **Required** | Test meets 3+ criteria: Critical/High priority, run frequently, time-consuming/tedious, stable requirements, high ROI, high defect yield, repetitive across configurations | Payment calculations, tax logic, menu sync, login, config download |
| **Manual** | Disqualified: unstable requirements, one-time execution, complex physical device interaction, unresolved env/data blockers, OR fewer than 3 criteria met | Font size check, screen layout at specific resolution, one-time migration validation |

**Default when unsure:** `Required`

### AIO Automation Status (What gets pushed to AIO)

| AIO Value | When to Use |
|-----------|-------------|
| `To Be Automated` | DEFAULT for all new cases. Always use on create unless overridden. |
| `Manual` | Use ONLY when source TC explicitly has `Automation Status: Manual` in its header |
| `Automated` | Use ONLY when 6_Automation/ contains executable scripts for this TC |
| `In Progress` | Use ONLY when automation is actively being written (rare) |

**Mapping rule:** Source `Required` → AIO `To Be Automated`. Source `Manual` → AIO `Manual`.

### Regression Potential (Validator Tags — NOT sent to AIO)

| Value | Criteria | Examples |
|-------|----------|----------|
| **High** | Critical Path. Affects Payments, Tax, Discounts, core Order flow (Add to Cart, Pay), Sync/Delta logic, Permissions/Access Control | OrderChannelId populated after sync, tax calculation, discount applied correctly |
| **Medium** | Secondary Logic. Affects reporting, UI display settings, features localized to specific store types, SystemStatus, background processes | Report totals, menu version display, background sync timing |
| **Low** | Visual/Non-Functional. Cosmetic UI changes, logging, rare edge cases with no financial impact | Log entry format, UI scroll performance, boundary count display |

**Default when unsure:** `Medium`

### Regression Candidate (Determines `Regression` tag)

| Value | Criteria |
|-------|----------|
| **Yes** | Assign when ANY of: (1) **Core Business Flow** — covers ordering, payments, login, sync, tax, discounts, permissions/access control. (2) **Bug Fix Verification** — ticket is linked to a bug that escaped to production or UAT. (3) **Cross-Module Integration** — tests an integration point between modules/services. (4) **Critical or High Priority** — aligns with exit criteria (100% Critical+High executed). (5) **High Daily Usage** — feature is used daily by cashiers/managers. |
| **No** | One-time migration/setup validations, exploratory/ad-hoc test notes, tests for features not yet released to production, cosmetic/visual-only validations, boundary/edge cases with no financial or functional impact. |

### Tag Mapping for AIO (Manual/CSV only)

| Tag | Source | Example |
|-----|--------|---------|
| `{TICKET_ID}` | Folder name | `POS-10611` |
| `v{VERSION}` | Folder path `Version {N}` | `v230` |
| `{Feature Area}` | Ticket's functional domain | `MenuSync`, `Payments`, `Employees` |
| `Regression` | Add ONLY if `Regression Candidate: Yes` | — |

**Non-regression TC tags:** `POS-10611, v230, MenuSync`
**Regression candidate TC tags:** `POS-10611, v230, MenuSync, Regression`

### Tags Determination Logic
Tags are NOT settable via REST API but MUST be tracked in the `AIO_SYNC_LOG.md` Custom Fields Status table with a `Tags` column.

**Base tags (all TCs in a sync batch):**
1. `{TICKET_ID}` — extracted from folder name (e.g., `POS-10593`)
2. `v{VERSION}` — extracted from folder path `Version {N}` (e.g., `v230`)
3. `{Feature Area}` — derived from the ticket's functional domain (e.g., `Reports`, `Payments`, `Checks`, `Employees`)

**Conditional tags:**
4. `Regression` — add ONLY if the source TC has `Regression Candidate: Yes`

**Example Tags column values:**
- Non-regression TC: `POS-10593, v230, Reports`
- Regression candidate TC: `POS-10593, v230, Reports, Regression`

## API Limitations (Confirmed)
- **Tags**: Accepted in create payload but do NOT persist via REST API. Must use AIO UI or CSV import.
- **Jira Linking**: `jiraTicket` param accepted but does NOT persist. Must use AIO UI or CSV import.
- **Custom Fields**: ✅ WORK via REST API. Use `customFields: [{"ID": 9, "value": "Yes"}, {"ID": 8, "value": "No"}]` with string values `"Yes"`/`"No"`. Do NOT use booleans (`true`/`false`) or numeric strings (`"1"`/`"0"`) — they fail or produce wrong values.
- **update_case**: Uses GET-merge-PUT pattern. Only send fields you want to change; existing data is preserved automatically.
- **update_case PUT is full replace**: The tool handles this internally by fetching existing data first.

## Step Mapping Format

From Markdown:
```
1. Launch POS and log in as cashier
   **Expected:** POS system loads successfully
2. Add 2 items to the check
   **Expected:** Items added, total displays $10.00
```

To AIO API:
```json
{
  "steps": [
    { "step": "Launch POS and log in as cashier", "expectedResult": "POS system loads successfully" },
    { "step": "Add 2 items to the check", "expectedResult": "Items added, total displays $10.00" }
  ]
}
```

Rules:
- Strip step numbers (`1.`, `2.`, etc.)
- Strip `**Expected:**` prefix from expected results
- Order is preserved automatically (API adds `order` field)

## Execution Pipeline

### 1. Resolve Folder ID
```
Call: aio-tests → get_folders (projectKey: "POS")
Match folder name from ticket directory to folder tree
Extract numeric ID
```

### 2. Check for Duplicates
```
Call: aio-tests → search_cases (projectKey: "POS", title: "POS-XXXX - Test Title")
If match found → use update_case with existing caseKey
If no match → use create_case
```

### 3. Push Test Case
```
Call: aio-tests → create_case or update_case
Always include: projectKey: "POS"
```

### 4. Log Results
After pushing, generate `AIO_SYNC_LOG.md` in the ticket folder with:
- Timestamp
- Cases created (with POS-TC-XXXX keys)
- Cases updated (with POS-TC-XXXX keys)
- Any errors encountered

## Known Folder IDs (Cache)
Update this list as new folders are discovered:
- `227734` — PROJ-4570 - Implement feature - Module C
- `227628` — Parent folder (Delta config downloads)

## Error Handling
- If `create_case` returns error → log and STOP, do not continue batch
- If `update_case` returns "Failed to fetch existing case" → case key is wrong, verify with `search_cases`
- If `get_folders` returns empty → check projectKey is `POS` not `QUPOS`

## Pre-Push Validation Checklist

Before calling `create_case` or `update_case`, verify EVERY case against this checklist. If any check fails, fix it before pushing.

| # | Check | WRONG Example | CORRECT Example |
|---|-------|---------------|-----------------|
| 1 | Title format: `POS-XXXX \| {Brief} : {Title}` | `TC-PROJ-1234-01: Normal open` | `PROJ-1234 \| Feature Name : Normal open — Time Clock Activity loads data` |
| 2 | Title has NO local TC ID prefix | `TC-PROJ-1234-01: ...` | `PROJ-1234 \| Feature Name : ...` |
| 3 | Description includes `**Test Data:**` section | `Verify that closing...` (no test data) | `Verify that closing...\n\n**Test Data:**\n- POS Module Bured...` |
| 4 | `automationStatus` = `To Be Automated` or `Manual` | `Manual Only`, `Required` | `To Be Automated` (default) or `Manual` (if source says Manual) |
| 5 | `priority` uses AIO values | `P0`, `P1`, `High` from source | `Critical`, `High`, `Medium` |
| 6 | Steps stripped of numbering | `1. Launch POS...` | `Launch POS...` |
| 7 | Steps stripped of `**Expected:**` prefix | `**Expected:** POS loads` | `POS loads successfully` |

| 8 | Description/precondition use real newlines | `"line1\\nline2"` (escaped literal) | Multi-line string with actual line breaks in the parameter value |
| 9 | Precondition sub-items use `  * ` indent | `Terminal 1: ...` on same line | `  * Terminal 1: AFREGO-DEV2 / 192.168.1.6` as indented sub-bullet |
| 10 | Source file is `_API.md` when it exists | Reading `_UPDATED.md` or `_PENDING.md` | Always prefer `_API.md` > `_OK.md` > `_PENDING.md` |
| 11 | `customFields` includes AI-Generated & AI-Automated | No `customFields` param | `customFields: [{"ID": 9, "value": "Yes"}, {"ID": 8, "value": "No"}]` |
| 12 | Tags column in Custom Fields Status table | No Tags column | Tags column with `{TICKET_ID}, v{VERSION}, {Area}` + `Regression` if applicable |

**This checklist is non-negotiable. Apply it on EVERY create and update call.**

## Source File Priority

When selecting which FINAL_TEST_CASES file to sync from, use this priority:

1. `FINAL_TEST_CASES_POS-XXXX_API.md` — Previously synced, human-approved, simplified
2. `FINAL_TEST_CASES_POS-XXXX_OK.md` — Human-approved, ready for sync
3. `FINAL_TEST_CASES_POS-XXXX_PENDING.md` — Agent-generated, awaiting review

**NEVER** use `_UPDATED.md` as the sync source when `_API.md` exists. The `_UPDATED.md` contains verbose/expanded steps not intended for AIO upload.

## String Formatting Rules

The AIO API accepts plain text with real newlines for `description` and `precondition` fields.

**CRITICAL**: Pass multi-line strings with actual line breaks in the parameter value. Do NOT use escaped `\n` sequences — they render as literal text in AIO UI.

### Precondition Format
```
- Top-level item one
- Top-level item two:
  * Sub-item A
  * Sub-item B
- Top-level item three
```

### Description Format
```
One-paragraph objective description.

**Test Data:**
- Key: Value
- Key: Value
```
