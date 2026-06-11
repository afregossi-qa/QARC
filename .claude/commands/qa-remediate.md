# QA Remediation Cycle

You are acting as **QA-Evidence-Reviewer + QA-Validator** for a remediation cycle. An UNSTABLE verdict requires revising test cases and re-testing.

**Trigger:** User has renamed `FINAL_CLOSURE_REPORT_*` → `FINAL_CLOSURE_REPORT_*_REMEDIATE.md`.

## Step 0 — RECALL (mandatory)

Read these files before doing anything else (skip if missing):
1. `.kiro/memory/universal/lessons_learned.md`
2. `.kiro/memory/products/{product}/lessons_learned.md`
3. `.kiro/memory/products/{product}/pattern_registry.md`

## Step 1 — Gather inputs

If `$ARGUMENTS` is provided, use it as the ticket folder path.
Otherwise ask: **Which ticket folder?** (e.g., `2026/Q2/Version 228/PROJ-1234 - Description`)

## Step 2 — Read workflow details

Read `.kiro/steering/qa-reviewer-workflow.md` for analysis standards.
Read `.kiro/steering/TestCasesDesign.md` for formatting.
Read `.kiro/skills/EvidenceAuditAnalyzer.md` for failure analysis.

## Step 3 — Determine iteration

Check `REMEDIATION_LOG.md` at ticket root:
- If absent: this is **R1**
- If present: increment the highest N found → **R{N+1}**

## Step 4 — Baseline current test cases

Copy `2_Validator/FINAL_TEST_CASES_*` to:
`5_Snapshots/FINAL_TEST_CASES_{TICKET_ID}_BASELINE_R{N}.md`

## Step 5 — Analyze failures

Using EvidenceAuditAnalyzer.md on `4_Reviewer/EXECUTION_FINDINGS_*.md`:
- Identify failed TC IDs and root causes
- Identify patterns in failures (common module, environment-specific, etc.)

## Step 6 — Update remediation log

Create or append to `REMEDIATION_LOG.md` at ticket root:

```
## Remediation Round {N} — {DATE}
| Field | Value |
|-------|-------|
| Iteration | R{N} |
| Failed TCs | {list} |
| Root causes | {summary} |
| Actions | {list of changes} |
| Status | IN_PROGRESS |
```

## Step 7 — Update test cases

Based on failure analysis:
- Adjust expected results where behavior is confirmed different
- Add new TCs for untested scenarios discovered during execution
- Mark removals if a TC is no longer valid

Save as `2_Validator/FINAL_TEST_CASES_{TICKET_ID}_PENDING.md` (overwrite if exists, single Write call).

## Step 8 — Finish

Stop. Tell the user:
> "Remediation R{N} complete. Review the revised test cases in `2_Validator/`. Re-execute the failed test cases, drop new evidence into `3_Evidence/`, then run `/qa-review`."
