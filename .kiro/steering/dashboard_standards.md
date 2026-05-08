---
inclusion: fileMatch
fileMatchPattern: '**/QA_DASHBOARD.md,**/SUMMARY.md'
---

# QA Dashboard Standards

## File Locations
- **Dashboard**: `QA_DASHBOARD.md` inside each ticket's folder (e.g., `POS-9969 - Description/QA_DASHBOARD.md`)
- **Summary**: `SUMMARY.md` inside each ticket's folder (e.g., `POS-9969 - Description/SUMMARY.md`)
- Both files live alongside `logic_explanation.md`, `test_plan_POS-[ID].md`, and the `Evidence/` subfolder.

## Dashboard & Summary Lifecycle
- **Initial Creation**: Both files are created when the ticket first reaches COMPLETED phase (closure report exists).
- **Updates**: Both files MUST be regenerated whenever:
  - Evidence is reviewed and closure reports are created or updated
  - Any ticket status changes
  - New evidence files are added
- **Timestamp**: Always update the "Last Updated" timestamp at the top of both files.
- **Preservation**: Maintain the overall structure when updating, only changing data and metrics.

## Project Lifecycle Phases
Define a ticket's status based on these file markers (checked in order):
1. **DISCOVERY**: `logic_explanation.md` exists.
2. **VETTED**: `test_plan_POS-[ID].md` exists (or `FINAL_TEST_CASES_[ID].md`).
3. **EXPORTED**: CSV export file exists (e.g., `POS-[ID]_*.csv` or `AIO_IMPORT_[ID].csv`).
4. **COMPLETED**: `./Evidence/FINAL_CLOSURE_REPORT_[ID].md` exists.

Note: A ticket can be in multiple phases. Use the highest phase achieved.

## QA_DASHBOARD.md Format

### UI & Formatting
- **Table Columns**: | Ticket ID | Title | Current Phase | Risk | Verdict | Last Audit |
- **Emojis**: 
  - STABLE: ✅
  - UNSTABLE: ❌
  - IN_PROGRESS: ⚠️
- **Metrics**: Include an "Executive Summary" section at the top showing:
  - Test Coverage (X/Y critical test cases)
  - Verdict
  - Phase
  - Open Issues count

### Verdict Calculation
- **STABLE**: All critical and high-priority test cases pass with valid evidence.
- **UNSTABLE**: Any critical failure or significant logic gap remains unaddressed.
- Tickets without closure reports show ⚠️ IN_PROGRESS

### Dashboard Content
The per-ticket QA_DASHBOARD.md must include:
1. Executive Summary table (coverage, verdict, phase)
2. Detailed status section listing all validated items
3. Open Issues (if any)
4. Files Present (list all files in the ticket folder including Evidence/)
5. Risk Summary
6. Next Actions

---

## SUMMARY.md Format

### Summary Structure
The per-ticket SUMMARY.md provides a narrative overview with the following sections:

1. **Header**: `# QA Analysis Summary: POS-[ID] - {Ticket Title}`
2. **Current Status**: Brief paragraph + status table (Verdict | Test Coverage | Phase)
3. **What's Been Validated**: Bullet points of validated functionality
   - For COMPLETED tickets: Extract key validations from closure reports and execution findings
   - Include specific data points (e.g., "Employees: 17 at startup, grew to 27 after creates")
   - Include specific evidence file references
4. **Design Notes**: Any design specifications relevant to this ticket
5. **What's Still Missing**: List of gaps or pending items (or "None" if fully validated)
6. **Documentation Structure**: Tree view of the ticket folder and all its files
7. **Next Actions**: Numbered list of recommended next steps
8. **Production Readiness**: Production readiness statement with justification

### Summary Content Rules
- Read `EXECUTION_FINDINGS_[ID].md` to extract validated functionality details
- Read `FINAL_CLOSURE_REPORT_[ID].md` to extract test coverage and verdict
- Read `logic_explanation.md` to extract scope, architecture, and identified gaps
- Read `test_plan_POS-[ID].md` to extract test case count and categories
- Include specific data points from evidence files (counts, entity names, timestamps)
- List all evidence files in the Documentation Structure section
- Reference related tickets where applicable (e.g., parallel testing dependencies)
