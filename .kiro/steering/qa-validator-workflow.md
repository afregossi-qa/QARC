---
inclusion: manual
---
# QA Validator Agent Workflow (v2.0 - Regression Gatekeeper)

## Mission
Finalize QA assets by merging AI drafts with human expertise and identifying high-value regression candidates for automation.

## Execution Steps

### Step 0: Memory Initialization
- Execute **Phase 1 (Recall)** of the `@CognitiveMemoryProtocol.md`. 
- Ensure you have read the latest `lessons_learned.md` before writing any Java code.

### 1. SYNC
- Read all assets from `Expert/` folder.
- Read steering file `@TestCasesDesign.md` for formatting standards.

### 2. INTEGRATE
- Merge human notes from `Expert/manual_input.md` into logic documentation.
- **Rule**: Human observations take precedence over AI-generated content.
- Preserve traceability to original sources.

### 3. STANDARDIZE & TAG (The Regression Gate)
- Rewrite all test cases to match `@TestCasesDesign.md` format.
- **Consolidation rule**: Merge specific validations into broader scenarios to reduce test bloat.
- **MANDATORY — Local Automation & Regression Tags**: For EVERY test case, you MUST assign the following tags in the TC header AND in the Test Summary Matrix. These tags are LOCAL ONLY (stored in the markdown files, never synced to AIO).
  - **Automation Status** — one of: `Required` | `Manual`
    - `Required`: Core financial/order flows, smoke tests, critical bug fixes, CRUD operations, sync/delta logic, permission flows.
    - `Manual`: Cosmetic changes, one-off exploratories, hardware-dependent, low-risk UI tweaks.
  - **Regression Potential** — one of: `High` | `Medium` | `Low`
    - `High`: Critical Path. Affects Payments, Tax calculations, Discount logic, or core Order flow (e.g., "Add to Cart", "Pay").
    - `Medium`: Secondary Logic. Affects reporting, UI display settings, or features localized to specific store types.
    - `Low`: Visual/Non-Functional. Cosmetic UI changes, logging, or rare edge cases with no financial impact.
  - **Regression Candidate** — one of: `Yes` | `No`
    - `Yes`: TC should be executed every release to catch regressions. Assign when ANY of:
      (1) **Critical Path** — TC covers Payments, Tax, Discounts, Order flow, Permissions/Access Control, or Sync logic
      (2) **Bug Fix Verification** — Ticket is a fix for a regression or breakage (keywords: "Fix", "Regression", "Breakage" in ticket description)
      (3) **Core Feature Gate** — TC validates a feature that other features depend on (e.g., login, config download, permission checks)
      (4) **High Regression Potential** — TC is already tagged `Regression Potential: High` regardless of automation status
    - `No`: TC does not need per-release execution. Cosmetic/visual-only validations, one-off exploratory scenarios, boundary/edge cases with no financial or functional impact, environment-specific checks (resolution, formatting) that don't regress functionally.
- **Format in TC header** (mandatory three lines after Test Type):
  ```
  **Automation Status:** Required
  **Regression Potential:** High
  **Regression Candidate:** Yes
  ```
- **Format in Test Summary Matrix** (mandatory three extra columns):
  ```
  | Test Case ID | Title | Priority | Test Type | Automation Status | Regression Potential | Regression Candidate |
  ```
- **NEVER skip these tags.** If unsure, default to `Required` / `Medium` and flag for human review.
- **NEVER include AIO tag update instructions** in the FINAL_TEST_CASES output. No "AIO Tag Update Instructions" sections, no tag ADD/REMOVE/KEEP tables. The Validator only writes local tags — AIO sync is handled separately by the AIO Direct Agent.

### 4. OUTPUT
Write to `Validator/` folder:
- `FINAL_TEST_CASES_{TICKET_ID}.md` — Formatted cases with `Automation Status` and `Regression Potential` in each TC header AND in the Test Summary Matrix (local-only tags, never synced to AIO).
- `{TICKET_ID}_TCMS_Import.csv` — TCMS-compatible export.

## Input/Output Mapping
| Read From | Write To |
|-----------|----------|
| Expert/manual_input.md | Validator/FINAL_TEST_CASES |
| Expert/test_plan_*.md | Validator/FINAL_TEST_CASES |
| Expert/logic_explanation.md | Validator/{TICKET_ID}_TCMS_Import |

## Post-Revision Integrity Check (MANDATORY after applying feedback)

When revising test cases based on QA feedback (`_UPDATED.md` comments), you MUST perform this integrity check BEFORE writing the final output:

### 1. Count Verification
- Count the total test cases in the **source file** (the `_UPDATED.md` or prior version)
- Count the total test cases in your **output draft**
- If counts differ, verify the difference is INTENTIONAL (explicitly requested removals/additions in the feedback)
- If any TC is missing that was NOT explicitly removed by feedback → **RE-ADD IT** with full content

### 2. Sequential Numbering Audit
- All TC IDs must be sequential with NO gaps: TC-001, TC-002, TC-003, ..., TC-NNN
- If TCs were removed, ALL subsequent TCs must be renumbered to close the gap
- The Test Summary Matrix MUST match the detailed sections 1:1 (same count, same IDs, same titles)

### 3. Content Completeness Check
For EVERY test case in the output, verify it has ALL required sections:
- `### TC-{TICKET_ID}-NNN: {Title}` (header)
- `**Priority:**` line
- `**Test Type:**` line
- `**Automation Status:**` line
- `**Regression Potential:**` line
- `**Regression Candidate:**` line
- `**Source:**` line
- `**Preconditions:**` section (with bullet list)
- `**Test Steps:**` section (numbered steps with `**Expected:**` for each)
- `**Expected Result:**` section
- `**Test Data:**` section

If ANY test case is missing a section, reconstruct it from the source file or Expert inputs.

### 4. Matrix-to-Detail Sync
- Every row in the Test Summary Matrix MUST have a corresponding detailed TC section below
- Every detailed TC section MUST have a corresponding row in the Matrix
- Mismatches = FAILURE — fix before writing output

### 5. Feedback Application Audit
At the top of the output file, add a revision comment block documenting:
- Which TCs were removed (and why)
- Which TCs were added (and why)
- Which TCs had preconditions/steps modified
- Final TC count before and after

**FAILURE MODE**: If you cannot reconstruct a missing TC from available sources, flag it with `<!-- MISSING: TC-NNN content could not be recovered — manual review required -->` in the output and note it in the revision comment.

## Quality Rules
- **Gatekeeping**: If a test case is tagged **[High]**, ensure the preconditions are extremely detailed, as this will be the input for the **Step Translator**.
- Human input ALWAYS overrides AI logic.
- No chat — execute and write files.