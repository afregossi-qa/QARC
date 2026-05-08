---
inclusion: manual
---

# QA Test Case Authoring Template

**Purpose:** Standard template for writing test cases that import cleanly into AIO Tests (TCMS). Follow this format so all QA team members produce consistent, importable test cases.

**Based on:** POS-9970 (Menu Lookup Delta Sync) — validated and imported successfully.

---

## Quick Reference

| Item | Format |
|------|--------|
| Test Case ID | `TC-001`, `TC-002`, etc. |
| Summary prefix | `{TICKET-ID} - {Title}` |
| Priority | P0 = Critical, P1 = High, P2 = Medium |
| Tags | `{TicketNumber},{Feature},{Category}` (PascalCase, no spaces) |
| Automation Status | "To be Automated", "Automated", or "Manual Only" |
| Steps | No "Step X:" prefix — just the action description |

---

## Part 1: Markdown Test Case Format

This is the format for writing test cases in the `{TICKET}_Critical_Test_Cases.md` file. The QA Exporter agent converts this into CSV for AIO import.

---

### Document Header

```markdown
# Critical Test Cases: {TICKET-ID} {Feature Name}

**Focus:** {Brief description of what's being tested}
**Priority:** P0 (Critical) and P1 (High) tests
**Generated from:** {Sources: Test Plan, Logic Explanation, Jira ticket, Developer comments}
**Version:** 1.0

---

## Test Summary

| Test ID | Title | Priority | Type | Tags |
|---------|-------|----------|------|------|
| TC-001 | {Title} | P0 (Critical) | {Functional/Integration/Regression/Negative} | {Tag1}, {Tag2} |
| TC-002 | {Title} | P1 (High) | {Type} | {Tag1}, {Tag2} |

**Total:** {N} test cases ({X} P0 Critical + {Y} P1 High)
**Automation Status:** To Be Automated
```

---

### Individual Test Case Structure

```markdown
### TC-001: {Descriptive Title}
**Priority:** P0 (Critical)
**Test Type:** {Functional | Integration | Regression | Negative | Data Integrity}
**Tags:** {TICKET-ID}, {Feature}, {Category1}, {Category2}
**Automation Status:** To Be Automated

**Objective:** {One sentence: what this test proves}

**Preconditions:**
- {Precondition 1 — environment, version, config}
- {Precondition 2 — data setup}
- {Precondition 3 — tools needed}

**Test Data:**
- {Data item 1: specific values}
- {Data item 2: specific values}
- {Expected outcomes with numbers}

**Test Steps:**
1. {Action the tester performs}
   **Expected:** {What should happen — be specific with values, counts, UI elements}
2. {Next action}
   **Expected:** {Specific outcome}
3. {Next action}
   **Expected:** {Specific outcome}

**Expected Result:** {Overall summary of what a passing test looks like — 2-3 sentences}
```

---

### Writing Guidelines

1. **Write for someone who doesn't know the product.** Every step should be self-contained — don't assume the tester knows where buttons are or what screens look like.

2. **Think like a cashier.** The end user is a cashier. Steps should reflect the actual workflow they'd follow, not internal system operations.

3. **Be specific with expected results.** Bad: "Data syncs correctly." Good: "105+ portion types present in MenuLookup.db with correct Title, CompanyId, Deleted=false fields."

4. **Include concrete test data.** Don't say "some items." Say "105 items in desk check environment" or "Order total: $10.03."

5. **One action per step.** Don't combine "Launch POS and verify all 3 collections sync" into one step. Split them.

6. **Mark critical context.** If a test has a dependency (e.g., "POS must be running, NOT restarted"), call it out with a **CRITICAL:** note before the preconditions.

7. **Tag consistently.** Always include the ticket number as the first tag. Use PascalCase for multi-word tags (e.g., `DeltaBased`, `ErrorHandling`, `MenuLookup`).

---

## Part 2: CSV Export Format (AIO Import)

The QA Exporter agent converts the markdown into this CSV format. If you're generating CSV manually, follow these rules exactly.

---

### Column Headers

```
Folder,Requirements,Existing Case ID,Summary,Description,Precondition,Test Steps,Expected Result,Priority,Tags,Automation Status
```

### Row Structure

Each test case spans **multiple rows** — one row per test step.

**First row (header row):** Contains ALL metadata.

| Column | Value |
|--------|-------|
| Folder | `"{TICKET-ID} - {Feature folder name}"` |
| Requirements | `{TICKET-ID}` |
| Existing Case ID | `TC-001` |
| Summary | `"{TICKET-ID} - {Test Case Title}"` |
| Description | Full objective + context + test data |
| Precondition | All preconditions (each on new line, starting with `- `) |
| Test Steps | First test step action only |
| Expected Result | Overall expected result for the entire test case |
| Priority | `Critical` / `High` / `Medium` |
| Tags | `"{TICKET-ID},{Tag1},{Tag2}"` |
| Automation Status | `"To be Automated"` |

**Subsequent rows (step rows):** Only identifiers + step details.

| Column | Value |
|--------|-------|
| Folder | Same as first row |
| Requirements | Same as first row |
| Existing Case ID | Same as first row |
| Summary | Same as first row |
| Description | EMPTY `""` |
| Precondition | EMPTY `""` |
| Test Steps | Next step action |
| Expected Result | Expected result for this specific step |
| Priority | EMPTY |
| Tags | EMPTY `""` |
| Automation Status | EMPTY `""` |

---

### CSV Rules

1. **No step numbering** — write `"Monitor API calls during initialization"` not `"Step 2: Monitor API calls during initialization"`
2. **Quote wrapping** — wrap any field containing commas, newlines, or quotes in double quotes
3. **Escape quotes** — use `""` (double double-quotes) inside quoted fields
4. **Blank line between test cases** — add an empty line between the last row of one TC and the first row of the next
5. **Consistent identifiers** — Folder, Requirements, Existing Case ID, and Summary must be identical across all rows of the same test case

---

### CSV Example (2 test cases)

```csv
Folder,Requirements,Existing Case ID,Summary,Description,Precondition,Test Steps,Expected Result,Priority,Tags,Automation Status
"POS-XXXX - Feature Name",POS-XXXX,TC-001,"POS-XXXX - Full Sync on Startup","Verify the system performs full sync on startup

Test Data:
- Collection A: 100 items
- Collection B: 50 items
- Environment: Dev","- POS vXXX deployed
- API accessible
- Network monitoring tools available
- Till claimed","Launch application (fresh startup)","All collections sync successfully via full sync. Data persisted to local DB. Timestamps stored for future delta syncs.",Critical,"POS-XXXX,DeltaBased,Integration,Startup","To be Automated"
"POS-XXXX - Feature Name",POS-XXXX,TC-001,"POS-XXXX - Full Sync on Startup","","","Monitor ALL outbound API calls during initialization","API calls captured for all endpoints",,"",""
"POS-XXXX - Feature Name",POS-XXXX,TC-001,"POS-XXXX - Full Sync on Startup","","","Verify call to GET /api/v4/collection-a WITHOUT modifiedFrom parameter","Full sync for Collection A (no query parameter on startup)",,"",""
"POS-XXXX - Feature Name",POS-XXXX,TC-001,"POS-XXXX - Full Sync on Startup","","","Inspect Collection A in local database","100+ items present with correct fields",,"",""
"POS-XXXX - Feature Name",POS-XXXX,TC-001,"POS-XXXX - Full Sync on Startup","","","Verify no errors in sync logs","All collections synced without errors",,"",""

"POS-XXXX - Feature Name",POS-XXXX,TC-002,"POS-XXXX - No Changes Background Sync","Verify empty delta returned when no changes exist

CRITICAL: Application must be running (not restarted) for background sync.

Test Data:
- Stored timestamps from TC-001
- All collections unchanged","- Application has completed initial full sync (TC-001 completed)
- Application is currently RUNNING (not restarted)
- No entities modified since last sync","Verify application is currently running (not restarted since TC-001)","All collections return empty delta during background sync. No data loss. All existing records unchanged.",Critical,"POS-XXXX,DeltaBased,Background","To be Automated"
"POS-XXXX - Feature Name",POS-XXXX,TC-002,"POS-XXXX - No Changes Background Sync","","","Wait for background sync cycle","Background sync initiated for all collections",,"",""
"POS-XXXX - Feature Name",POS-XXXX,TC-002,"POS-XXXX - No Changes Background Sync","","","Monitor API call with modifiedFrom={stored_timestamp}","URL contains ?modifiedFrom={stored_timestamp} — incremental mode",,"",""
"POS-XXXX - Feature Name",POS-XXXX,TC-002,"POS-XXXX - No Changes Background Sync","","","Verify response indicates no changes","Empty arrays or isFullDataSet: false with no records",,"",""
"POS-XXXX - Feature Name",POS-XXXX,TC-002,"POS-XXXX - No Changes Background Sync","","","Verify no data loss in local database","All records present with original data",,"",""
```

---

## Part 3: Standard Tags Reference

| Domain | Tags |
|--------|------|
| Delta sync | `DeltaBased` |
| Employees | `Employees` |
| Shared Employees | `SharedEmployee` |
| Job Titles | `JobTitle` |
| Menu Lookups | `MenuLookup`, `PortionType`, `PreparationInstruction`, `Tag` |
| Terminal Config | `TerminalConfig`, `ScannerModels` |
| Permissions | `PermissionCache` |
| Error handling | `ErrorHandling` |
| API validation | `API` |
| Configuration | `Configuration` |
| Persistence | `Persistence` |
| Integration tests | `Integration` |
| Regression tests | `Regression` |
| Background sync | `Background` |
| Startup sync | `Startup` |

---

## Part 4: Priority Mapping

| Internal Priority | AIO Priority | Description |
|-------------------|-------------|-------------|
| P0 | Critical | Must pass before production |
| P1 | High | Should pass, non-blocking |
| P2 | Medium | Nice to have |

---

## Part 5: File Naming Convention

| File | Name Pattern | Location |
|------|-------------|----------|
| Test cases (markdown) | `{TICKET}_Critical_Test_Cases.md` | Ticket folder root |
| Test cases (CSV) | `{TICKET}_Critical_Test_Cases.csv` | Ticket folder root |
| Logic explanation | `logic_explanation.md` | Ticket folder root |
| Test plan | `test_plan_{TICKET}.md` | Ticket folder root |
| Manual input | `manual_input.md` | Ticket folder root |
| Evidence | `*.json`, `*.png` | `Evidence/` subfolder |

---

**Version:** 1.0
**Last Updated:** March 17, 2026
**Based on:** POS-9970, POS-9969, POS-9967, POS-10302 validated test case formats
