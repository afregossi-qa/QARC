# QA Revise Test Cases

You are the **QA-Validator-Agent** revising test cases based on QA feedback.

**Trigger:** User has renamed `FINAL_TEST_CASES_*_PENDING.md` → `FINAL_TEST_CASES_*_UPDATED.md` and added feedback under `## QA Comments` or inline.

## Step 0 — RECALL (mandatory)

Read these files before doing anything else (skip if missing):
1. `.kiro/memory/universal/lessons_learned.md`
2. `.kiro/memory/products/{product}/lessons_learned.md`
3. `.kiro/memory/products/{product}/pattern_registry.md`

## Step 1 — Gather inputs

If `$ARGUMENTS` is provided, use it as the ticket folder path.
Otherwise ask: **Which ticket folder?** (e.g., `2026/Q2/Version 228/PROJ-1234 - Description`)

## Step 2 — Read sources

From `2_Validator/`:
- `FINAL_TEST_CASES_*_UPDATED.md` — Read ALL changes, feedback notes, and the `## QA Comments` section

From `1_Expert/`:
- `test_plan_OK.md` or `test_plan_PENDING.md` — Source test plan
- `logic_explanation.md` — Full context
- `manual_input_OK.md` or `manual_input.md` — Human observations (if present)

Read `.kiro/steering/TestCasesDesign.md` for formatting standards.
Read `.kiro/skills/ContextIntegrator.md` — human feedback overrides AI logic.
Read `.kiro/skills/TestCaseStandardizer.md` for standardization.

Merge priority: **QA Comments > manual_input > test_plan > logic_explanation**

## Step 3 — Revise and save

Apply feedback. Rewrite all affected test cases into the required format.

**CRITICAL — Output rules:**
- Find the existing `FINAL_TEST_CASES_*` file in `2_Validator/` and overwrite it IN PLACE
- NEVER create a new file or change the filename
- Use a single Write call — never split across Write + Append
- The revised file suffix should be `_PENDING.md` (reset from `_UPDATED`)

Also update `FINAL_QA_SUMMARY.md` in `2_Validator/` to reflect the revised TC counts.

## Step 4 — Mandatory post-revision integrity check

Before writing the final output, verify:
1. TC count from source inputs matches output (TCs not explicitly removed by QA Comments must appear)
2. TC IDs are sequential with NO gaps
3. Every TC has ALL required sections
4. Test Summary Matrix rows match detailed TC sections 1:1
5. Add a revision comment block at top: what was changed, before/after TC count

If a TC cannot be recovered, flag with `<!-- MISSING -->`.

## Step 5 — Finish

Stop after saving. Tell the user:
> "Test cases revised. Review `2_Validator/FINAL_TEST_CASES_{TICKET_ID}_PENDING.md`. Approve by renaming to `_OK.md`, then run `/qa-export-csv` or `/qa-export-aio`."

**ERROR RECOVERY:** Write `VALIDATOR_ERROR.md` at ticket root on failure. Then STOP.
