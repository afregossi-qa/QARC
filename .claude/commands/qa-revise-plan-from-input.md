# QA Draft Test Plan from Manual Input

You are the **QA-Expert-Agent** drafting or revising the test plan after the QA tester has filled in `manual_input_OK.md`.

**Trigger:** User has filled `manual_input.md` with tester observations and renamed it to `manual_input_OK.md`.

## Step 0 — RECALL (mandatory)

Read these files before doing anything else (skip if missing):
1. `.kiro/memory/universal/lessons_learned.md`
2. `.kiro/memory/products/{product}/lessons_learned.md`
3. `.kiro/memory/products/{product}/pattern_registry.md`
4. `.kiro/memory/products/{product}/project_context.md`

## Step 1 — Gather inputs

If `$ARGUMENTS` is provided, use it as the ticket folder path.
Otherwise ask: **Which ticket folder?** (e.g., `2026/Q2/Version 228/PROJ-1234 - Description`)

## Step 2 — Read sources

From `1_Expert/`:
- `manual_input_OK.md` — Human observations (required)
- `logic_explanation.md` — Full context (required)

Read `.kiro/skills/GapAnalyzer.md` for coverage validation.

## Step 3 — Draft test plan

Using manual input as the primary context (it overrides AI assumptions):
- Draft a comprehensive test plan per the format in `.kiro/steering/TestCasesDesign.md`
- Apply GapAnalyzer.md to validate coverage of requirements vs. implementation
- Include `## Notes` section at the top for QA comments

## Step 4 — Cleanup and save

**CLEANUP RULE:** Before saving, list `1_Expert/` and find all existing `test_plan*.md` files. For each one:
1. Copy to `5_Snapshots/` with timestamp suffix
2. Delete from `1_Expert/`

Save the output as `1_Expert/test_plan_PENDING.md`. Only ONE test plan must exist at a time.

## Step 5 — Finish

Stop after saving. Tell the user:
> "Test plan drafted from manual input. Review `1_Expert/test_plan_PENDING.md`. Approve by renaming to `test_plan_OK.md` then run `/qa-validate`."

**ERROR RECOVERY:** Write `EXPERT_ERROR.md` at ticket root on failure. Then STOP.
