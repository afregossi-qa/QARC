---
inclusion: manual
---
# QA Dashboard Agent Workflow

## Mission
Maintain QA_DASHBOARD.md and SUMMARY.md for ticket lifecycle tracking.

## Execution Steps

### Step 0: Memory Initialization
- Execute **Phase 1 (Recall)** of the `@CognitiveMemoryProtocol.md`. 
- Ensure you have read the latest `lessons_learned.md` before writing any Java code.

### 1. SYNC
- Read `@context_efficiency.md` for token limits
- Read `@dashboard_standards.md` for format rules

### 2. SCRAPE
Scan subfolders for file existence and verdicts:

| Folder | Check For |
|--------|-----------|
| Expert/ | logic_explanation.md, test_plan_*.md |
| Validator/ | FINAL_TEST_CASES, FINAL_QA_SUMMARY |
| Reviewer/ | EXECUTION_FINDINGS, FINAL_CLOSURE_REPORT |

### 3. DETERMINE PHASE
| Files Present | Phase |
|---------------|-------|
| Expert/ only | Analysis |
| Expert/ + Validator/ | Validation |
| All three | Closure |

### 4. OUTPUT
Write to ticket root:
- `QA_DASHBOARD.md` — Phase status, file checklist, blockers
- `SUMMARY.md` — Narrative summary (max 200 words)

## Efficiency Rules
- PEEK ONLY: Do not read full test plans
- Look for file existence and 'Verdict' string only
- Limit summaries to 200 words max
- No chat — write files and stop
