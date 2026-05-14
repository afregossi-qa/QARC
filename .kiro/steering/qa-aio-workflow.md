---
inclusion: manual
---
# QA AIO Direct Agent Workflow

## Mission
Sync validated test cases to AIO Tests API. Full CRUD: create, update, delete.

## Execution Steps

### 0. Step 0: Memory Initialization
- Execute **Phase 1 (Recall)** of the `@CognitiveMemoryProtocol.md`. 
- Ensure you have read the latest `lessons_learned.md` before writing any Java code.

### 1. LOAD PRIOR STATE
- Read `AIO_SYNC_LOG.md` from ticket root (if exists)
- Parse table: Local ID (TC-01) → AIO Key (POS-TC-8880)
- No log = create-only mode

### 2. PARSE CURRENT STATE
- Read `Validator/FINAL_TEST_CASES_*_API.md`
- Extract: TC IDs, titles, priority, steps, preconditions, expected results, test data
- **EXCLUDE local-only fields**: `Automation Status: Required | Manual` and `Regression Potential: High | Medium | Low` from TC headers are internal pipeline tags for the Validator, Regression Architect, and Translator agents. Do NOT send these to AIO. The AIO `automationStatus` field uses its own values (`To Be Automated`, `In Progress`, `Automated`, `Manual`).

### 2.1 FORMAT TEST CASE TITLES
- Every test case title MUST follow: `POS-XXXX | {Feature Brief} : {Test Case Title}`
- The **Feature Brief** is a short 2-5 word descriptor of the ticket's feature area, derived from the folder name or Jira summary
- Example: `PROJ-1234 | SOD Forecast Print : Hourly Section Display with Data`
- Example: `PROJ-1234 | TC Activity Reload : Auto-logoff from Time Clock screen — no reload`
- Extract ticket ID from folder name (e.g., `PROJ-1234 - POS Start of Day - Print Forecast by Hour` → `PROJ-1234`)
- The feature brief MUST be identical across all test cases for the same ticket
- If title already has the full prefix, do not duplicate it

### 2.2 FORMAT DESCRIPTION FIELD
- The description field MUST include the Test Data section from the source test case
- Format:
  ```
  {Test case objective/description}
  
  **Test Data:**
  {All test data items from the source, preserving bullet points or formatting}
  ```
- If no Test Data section exists, include only the objective/description
- Always preserve API endpoints, environment info, and sample data values

### 3. DIFF & EXECUTE
| Condition | Action |
|-----------|--------|
| Local ID not in sync log | `aio-tests:create_case` |
| Local ID in sync log | `aio-tests:update_case` (full content) |
| AIO Key in log, Local ID removed | DELETE via API |

### 4. GET TARGET FOLDER
- Use `aio-tests:get_folders` to find 'AI Generated' folder
- Create folder if not exists

### 5. REGENERATE SYNC LOG
Write `AIO_SYNC_LOG.md` to ticket root:
- Synced Test Cases table with action taken (Created/Updated)
- Deleted Test Cases section for audit trail

## Priority Mapping
| Local | AIO |
|-------|-----|
| P0 | Critical |
| P1 | High |
| P2 | Medium |

## Critical Rules
- Only execute on user demand (never auto-run)
- Always link cases to Jira ticket from folder name
- `AIO_SYNC_LOG.md` is single source of truth — never guess keys
- Send complete case content on updates (no partial updates)
- Log deleted case key + title for traceability
- On API error: log detail and STOP

## Formatting Standards (MANDATORY — never skip)

### Title: `POS-XXXX | {Feature Brief} : {Test Case Title}`
- Extract ticket ID from folder name
- Derive feature brief (2-5 words) from ticket description
- NEVER include local TC ID prefix (TC-POS-XXXX-NN) in AIO title
- Use pipe `|` after ticket ID, colon `:` before test case title
- Feature brief must be identical across all TCs for the same ticket

### Description: Must include `**Test Data:**` section
- Always append test data below the objective text
- If source has no explicit Test Data, extract from preconditions/environment

### Automation Status: Always `To Be Automated`
- Source file's `Automation Status: Manual/Required` is an internal pipeline tag
- AIO field must always be `To Be Automated` on create/update

### Sync Log: Must match reference format
- Reference: `2026/Q1/Version 227/PROJ-1234 - .../AIO_SYNC_LOG.md`
- Required sections: Sync Summary, Update History, Test Case Mapping, Priority Distribution, AIO Tests Links, Notes
- Must include `⚠️ Manual action required: Add tags and Jira links in AIO UI`
