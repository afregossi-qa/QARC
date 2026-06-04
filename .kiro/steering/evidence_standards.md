---
inclusion: fileMatch
fileMatchPattern: '**/Evidence/**'
---

# Evidence Review & Archiving Standards

## Folder Structure
- **Evidence Source**: All raw execution data (screenshots, logs, API responses) is located in the `./Evidence/` sub-folder of the ticket directory.
- **Expert Output**: Logic explanations, manual input, and test plans are saved in the `./Expert/` sub-folder.
- **Validator Output**: Finalized test cases, CSV exports, and QA summaries are saved in the `./Validator/` sub-folder.
- **Reviewer Output**: Execution findings and closure reports are saved in the `./Reviewer/` sub-folder.
- **Cross-cutting files**: AIO sync log, dashboard, and summary remain in the ticket root folder.

## Reporting Requirements
- **Findings Document**: Named `EXECUTION_FINDINGS_[Ticket_ID].md`. It must contain a Traceability Matrix mapping Test Cases to specific evidence filenames.
- **Closure Report**: Named `FINAL_CLOSURE_REPORT_[Ticket_ID].md`. It must provide the final stability verdict.

## Report Lifecycle
- **Initial Creation**: Reports are created when first analyzing evidence for a ticket.
- **Updates**: When new evidence is added or existing evidence is updated, reports MUST be regenerated to reflect the current state.
- **Timestamp**: Always update the "Generated" timestamp when updating reports to track the latest analysis date.
- **Preservation**: Maintain the overall report structure and format when updating, only changing metrics, statuses, and analysis based on current evidence.

## Evidence Naming Convention
Evidence files can be named freely — the validation gate uses content-based analysis to match files to test cases. However, following the `tc{NN}_{short_description}.{ext}` pattern enables faster filename-based matching (Pass 1) and makes the Evidence/ folder easier to scan visually.

Recommended pattern examples:
- `tc01_enable_test_mode.json` → TC-01
- `tc02_disable_test_mode.png` → TC-02
- `tc03_banner_persists_restart.json` → TC-03

Acceptable alternatives (content-based matching will handle these):
- `backgroundsync_after_update.json` → agent reads content, maps to relevant TCs
- `freshstart_employees.json` → agent identifies which TCs this covers
- `permission_cache.json` → single file can cover multiple TCs

A single evidence file can cover multiple test cases if its content is relevant to more than one scenario.

## Evidence Validation Gate
Before the reviewer is invoked, the `trigger-reviewer` hook runs a two-pass automated validation:

**Pass 1 — Filename pattern match (fast):**
Checks if filenames start with `tc{NN}_`. If matched, maps directly to TC-{NN}.

**Pass 2 — Content-based analysis (for unmatched TCs only):**
Reads unmatched evidence files and analyzes content looking for:
- API endpoint paths matching test case steps
- HTTP status codes matching expected results
- Entity names, IDs, or types referenced in the test case
- Action keywords (delta sync, fresh start, background sync, permission)
- Error messages or response bodies corresponding to expected/actual results

**Decision logic:**
- All P0/P1 covered (via either pass) → reviewer proceeds
- Any P0/P1 missing after both passes → `Evidence/EVIDENCE_GAP_REPORT.md` produced, reviewer blocked
- P2 missing → logged as warning, does not block
- QA tester adds missing evidence and re-triggers the **"Validate Evidence & Review"** hook to retry

### EVIDENCE_GAP_REPORT.md
Generated automatically when evidence gaps are detected. Contains:
- Coverage matrix: TC ID | Priority | Evidence File | Status (COVERED/MISSING/WARNING)
- Verdict: BLOCKED or PASSED
- Instructions for the QA tester to resolve gaps

## Verdict Definitions
- **STABLE**: All critical and high-priority test cases pass with valid evidence.
- **UNSTABLE**: Any critical failure or significant logic gap remains unaddressed.

## Analysis Integrity Standards

These rules apply to ALL agents performing ANY evidence or log analysis — not just the Reviewer. They are non-negotiable.

1. **Facts only**: Every claim must be traceable to a specific evidence file, line number, or timestamp. If it cannot be cited, it cannot be stated as fact.
2. **Binary files**: LiteDB (.db) files MUST be read using `Tools/LiteDbReader5/bin/Debug/net6.0/LiteDbReader5.exe`. Images (.png/.jpg) MUST be read using the `read_file` tool. Only state "not analyzed" if the tool fails after attempting all strategies.
3. **No extrapolation**: If behavior X was observed in scenario A, do not claim it also occurs in scenario B unless scenario B was independently tested with its own evidence.
4. **Observation vs interpretation**: Findings must clearly separate what was observed (data) from what it means (analysis). Use explicit labels like "OBSERVATION:" and "INTERPRETATION:".
5. **Honest gaps**: If evidence for a test case is weak (e.g., tester notes only, no log/screenshot), mark it as "weak evidence — tester notes only" rather than upgrading it to full coverage.
6. **Correlation ≠ causation**: When comparing two test runs with different configurations, state the observed correlation (e.g., "error absent in run B") but do NOT claim one variable caused the change unless the mechanism is proven at the code level. Other variables may have changed between runs (timing, test patterns, environment state).
7. **User-reported observations**: When the tester verbally confirms a behavior (e.g., "checks are visible"), note it as "tester-reported" — not as log-verified evidence.