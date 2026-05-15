---
inclusion: manual
---

# QA Agent Workflows

> Load this file only when executing a specific workflow. Do not auto-include.

### Step 0: Memory Initialization
- Execute **Phase 1 (Recall)** of the `@CognitiveMemoryProtocol.md`. 
- Ensure you have read the latest `lessons_learned.md` before writing any Java code.

## EXPERT_OK → Validator Workflow

1. If `Validator/FINAL_TEST_CASES_*` exists, read it first — extract `## QA Comments` section
2. Read `Expert/test_plan_*.md`, `Expert/manual_input.md`, `Expert/logic_explanation.md`
3. Apply @TestCasesDesign.md formatting
4. Use @ContextIntegrator.md to merge (priority: QA Comments > manual_input > test_plan > logic_explanation)
5. Use @TestCaseStandardizer.md for format
6. Save `Validator/FINAL_TEST_CASES_{ticketId}_PENDING.md` (preserve `## QA Comments` content at top)
7. Save `Validator/FINAL_QA_SUMMARY.md`
8. Update `.state.json` via @LifecycleStateManager.md transitionTo: phase=VALIDATOR_PENDING, agent=QA-Validator-Agent, note="Generated FINAL_TEST_CASES from approved test plan."

## VALIDATOR_CSV → Exporter Workflow

1. Read `Validator/FINAL_TEST_CASES_*_OK.md`
2. Apply @csv-export-format.md
3. Save `Validator/{ticketId}_TCMS_Import.csv`
4. Update `.state.json` via @LifecycleStateManager.md transitionTo: phase=EXECUTION_PENDING, agent=QA-Exporter-Agent, note="CSV export generated from approved test cases."

## VALIDATOR_API → AIO Sync Workflow

1. Read `Validator/FINAL_TEST_CASES_*_OK.md`
2. Use AIO Tests MCP tools to sync
3. Save `AIO_SYNC_LOG.md`
4. Update `.state.json` via @LifecycleStateManager.md transitionTo: phase=EXECUTION_PENDING, agent=QA-AIO-Direct-Agent, note="Test cases synced to AIO Tests."

## REVIEWER_PENDING → Reviewer Workflow

1. Read `Validator/FINAL_TEST_CASES_*.md`
2. List `Evidence/` files (exclude EVIDENCE_READY.md)
3. Apply Head/Tail rule: files >100 lines → first 50 + last 50
4. Use @EvidenceAuditAnalyzer.md for matching
5. Use @ReportLifecycleUpdater.md for reports
6. Save `Reviewer/EXECUTION_FINDINGS_{ticketId}.md`
7. Save `Reviewer/FINAL_CLOSURE_REPORT_{ticketId}.md`
8. Determine verdict (STABLE/UNSTABLE)
9. Update `.state.json` via @LifecycleStateManager.md setVerdict: verdict={STABLE|UNSTABLE}, agent=QA-Evidence-Reviewer-Agent, note="Verdict based on evidence analysis: {brief reason}."

## UNSTABLE → Remediation Workflow

1. Read `Reviewer/EXECUTION_FINDINGS_*.md`
2. Identify failed TC IDs and reasons
3. Copy current test cases to `Snapshots/FINAL_TEST_CASES_*_BASELINE_R{N}.md`
4. Update/create `REMEDIATION_LOG.md`
5. Adjust test cases based on failures
6. Save `Validator/FINAL_TEST_CASES_*_PENDING.md`
7. Update `.state.json` via @LifecycleStateManager.md transitionTo: phase=REMEDIATION_R{N}, agent=Remediation-Workflow, note="Remediation round {N}: adjusted {count} test cases based on failures."
