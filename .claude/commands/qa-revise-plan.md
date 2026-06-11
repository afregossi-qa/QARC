# QA Revise Test Plan

You are the **QA-Expert-Agent** revising an existing test plan based on QA feedback.

**Trigger:** User has renamed `test_plan_PENDING.md` → `test_plan_UPDATED.md` and added feedback notes at the top.

## Step 0 — RECALL (mandatory)

Read these files before doing anything else (skip if missing):
1. `.kiro/memory/universal/lessons_learned.md`
2. `.kiro/memory/products/{product}/lessons_learned.md`
3. `.kiro/memory/products/{product}/pattern_registry.md`

## Step 1 — Gather inputs

If `$ARGUMENTS` is provided, use it as the ticket folder path.
Otherwise ask: **Which ticket folder?** (e.g., `2026/Q2/Version 228/PROJ-1234 - Description`)

## Step 2 — Read sources

From `1_Expert/`:
- `test_plan_UPDATED.md` — Read the feedback notes at the top
- `logic_explanation.md` — Full context
- `manual_input_OK.md` or `manual_input.md` — Human observations (if present)

Read `.kiro/skills/GapAnalyzer.md` for gap coverage validation.

## Step 3 — Rewrite

Incorporate all feedback from `test_plan_UPDATED.md`. Use GapAnalyzer.md to validate that the revised plan covers all requirements vs. implementation gaps.

## Step 4 — Cleanup and save

**CLEANUP RULE:** Before saving, list `1_Expert/` and find all existing `test_plan*.md` files. For each one found:
1. Copy it to `5_Snapshots/` with a timestamp suffix (e.g., `test_plan_UPDATED_2026-01-15T10-30-00.md`)
2. Delete it from `1_Expert/`

Then save the revised plan as `1_Expert/test_plan_PENDING.md`. Only ONE test plan file must exist at a time.

## Step 5 — Finish

Stop after saving. Tell the user:
> "Test plan revised. Review `1_Expert/test_plan_PENDING.md`. Approve by renaming to `test_plan_OK.md` then run `/qa-validate`."

**ERROR RECOVERY:** Write `EXPERT_ERROR.md` at ticket root on failure. Then STOP.
