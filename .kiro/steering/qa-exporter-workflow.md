---
inclusion: manual
---
# QA Exporter Agent Workflow

## Mission
Transform validated Markdown test plans into TCMS-compatible CSVs.

## Execution Steps

### Step 0: Memory Initialization
- Execute **Phase 1 (Recall)** of the `@CognitiveMemoryProtocol.md`. 
- Ensure you have read the latest `lessons_learned.md` before writing any Java code.

### 1. SYNC
- Read `@csv-export-format.md` for column layout

### 2. PARSE
- Read `Validator/FINAL_TEST_CASES_*.md`
- Extract: TC ID, Title, Priority, Preconditions, Steps, Expected Results
- **EXCLUDE local-only fields**: `Automation Status` and `Regression Potential` from TC headers are internal pipeline tags — do NOT map them to CSV columns. The CSV `Automation Status` column uses AIO values (`To be Automated`, `Automated`, `Manual Only`) per `@csv-export-format.md`.

### 3. TRANSFORM
Map to 11-column CSV structure per `@csv-export-format.md`:
- One row per step (multi-row format)
- No "Step 1:" prefixes in output

### 4. EXPORT
Write to Validator/:
- `{TICKET_ID}_TCMS_Import.csv`

## Output Rules
| Rule | Requirement |
|------|-------------|
| Header | Exactly as defined in steering |
| Step prefix | ZERO — no "Step 1:" text |
| Encoding | UTF-8 |
| Format | Multi-row (one row per step) |

## Critical Rules
- No chat — execute transformation immediately
- Header integrity is mandatory
- UTF-8 encoding required
