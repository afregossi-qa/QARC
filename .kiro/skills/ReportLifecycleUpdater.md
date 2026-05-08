# Skill: Report-Lifecycle-Updater
**Objective**: Manage the creation and update of audit reports in `4_Reviewer/`. Produces TWO files: EXECUTION_FINDINGS and FINAL_CLOSURE_REPORT.

## Output Files (BOTH required)

| File | Path | Purpose |
|------|------|---------|
| `EXECUTION_FINDINGS_POS-{TICKET}.md` | `4_Reviewer/` | Detailed per-TC evidence analysis with log excerpts |
| `FINAL_CLOSURE_REPORT_POS-{TICKET}.md` | `4_Reviewer/` | Executive summary, acceptance criteria, verdict, production readiness |

**CRITICAL**: You MUST generate BOTH files. The closure report is NOT optional — it is the final deliverable that stakeholders review.

## Transformation Procedure

### Step 1: File Detection
Check for existing `EXECUTION_FINDINGS` and `FINAL_CLOSURE_REPORT` in `4_Reviewer/`.

### Step 2: Generate EXECUTION_FINDINGS
- Per-TC evidence analysis with actual log excerpts
- Evidence file → test case mapping (filename match + content analysis)
- Key log lines with timestamps, file names, and line references
- Verdict per test case: PASS / FAIL / BLOCKED

### Step 3: Generate FINAL_CLOSURE_REPORT
Structure (all sections required):

```
# Final Closure Report: POS-{TICKET}
## {Ticket Title}

**Generated:** {date}
**Auditor:** QA Evidence Review
**Verdict:** {STABLE/UNSTABLE}

## Executive Summary
- Key Metrics table (TCs defined, TCs with evidence, coverage %)
- Verdict rationale (1-2 sentences)

## Evidence Inventory
- Table of all evidence files with terminal, context, size

## Test Coverage Audit
- Table: TC | Priority | Verdict | Key Evidence

## Acceptance Criteria Validation
- One subsection per AC with Status: VALIDATED/NOT VALIDATED
- Include key log excerpts from evidence

## Logic Gaps & Known Limitations
- Table from test plan with current status

## Risk Assessment
- Resolved Risks (numbered list)
- Remaining Risks

## Stability Verdict
- Verdict: STABLE or UNSTABLE
- Rationale (bullet points)

## Production Readiness
- Blocking Issues
- Required Actions Before Production

## Conclusion
- 1-paragraph summary

## Footer
- Report Generated date, Final Verdict, Production Ready status
```

### Step 4: Delta Update Logic (for re-runs)
- If files exist: Read current metrics and matrix
- Merge new audit results — replace old PASS/FAIL only if new evidence is more recent
- Recalculate: Total TCs vs Executed, % Passed vs % Failed

### Step 5: Verdict Engine
Apply `STABLE/UNSTABLE` logic from `@evidence_standards.md`:
- STABLE: All P0/P1 test cases PASS
- UNSTABLE: Any P0/P1 test case FAIL or MISSING evidence

### Step 6: Metadata Refresh
Update "Generated" timestamp to current system date.

### Step 7: FS Write
Write BOTH files to `4_Reviewer/` (NOT `./Evidence/`).

## Anti-Patterns
- Writing to `./Evidence/` — WRONG folder, must be `4_Reviewer/`
- Generating only EXECUTION_FINDINGS without FINAL_CLOSURE_REPORT
- Skipping the closure report because findings are enough
- Missing Acceptance Criteria section in closure report