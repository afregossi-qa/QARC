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
- **Format in TC header** (mandatory two lines after Test Type):
  ```
  **Automation Status:** Required
  **Regression Potential:** High
  ```
- **Format in Test Summary Matrix** (mandatory two extra columns):
  ```
  | Test Case ID | Title | Priority | Test Type | Automation Status | Regression Potential |
  ```
- **NEVER skip these tags.** If unsure, default to `Required` / `Medium` and flag for human review.
- **NEVER include AIO tag update instructions** in the FINAL_TEST_CASES output. No "AIO Tag Update Instructions" sections, no tag ADD/REMOVE/KEEP tables. The Validator only writes local tags — AIO sync is handled separately by the AIO Direct Agent.

### 4. OUTPUT
Write to `Validator/` folder:
- `FINAL_TEST_CASES_{TICKET_ID}.md` — Formatted cases with `Automation Status` and `Regression Potential` in each TC header AND in the Test Summary Matrix (local-only tags, never synced to AIO).
- `FINAL_QA_SUMMARY_{TICKET_ID}.md` — Executive overview, risk assessment, and a **Regression Priority List** (highlighting all [High] cases) with automation readiness metrics.
- `{TICKET_ID}_TCMS_Import.csv` — TCMS-compatible export.

## Input/Output Mapping
| Read From | Write To |
|-----------|----------|
| Expert/manual_input.md | Validator/FINAL_TEST_CASES |
| Expert/test_plan_*.md | Validator/FINAL_QA_SUMMARY |
| Expert/logic_explanation.md | Validator/{TICKET_ID}_TCMS_Import |

## Quality Rules
- **Gatekeeping**: If a test case is tagged **[High]**, ensure the preconditions are extremely detailed, as this will be the input for the **Step Translator**.
- Human input ALWAYS overrides AI logic.
- No chat — execute and write files.