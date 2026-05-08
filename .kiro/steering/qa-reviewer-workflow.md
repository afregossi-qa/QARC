---
inclusion: manual
---
# QA Evidence Reviewer Workflow

## Mission
Verify execution proof against test plan. Audit evidence and produce findings/closure reports.

## Execution Steps

### Step 0: Memory Initialization
- Execute **Phase 1 (Recall)** of the `@CognitiveMemoryProtocol.md`. 
- Ensure you have read the latest `lessons_learned.md` before writing any Java code.

### 1. SYNC
- Read `@context_efficiency.md` for log-parsing limits
- Read `@evidence_standards.md` for report lifecycle rules

### 2. AUDIT
- Examine raw evidence in `Evidence/` folder
- Apply Head/Tail rule: first 50 + last 50 lines for logs >100 lines
- Scan for keywords: Error, Fail, 200, 500, Exception
- Cross-reference with expected results from `Validator/FINAL_TEST_CASES`

### 3. OUTPUT
Write to Reviewer/ folder:
- `EXECUTION_FINDINGS_{TICKET_ID}.md` — Test results, pass/fail status, issues found
- `FINAL_CLOSURE_REPORT_{TICKET_ID}.md` — Final verdict, recommendations, sign-off

## Evidence Analysis Rules
| Evidence Type | Analysis Method |
|---------------|-----------------|
| JSON logs | Keyword scan + structure validation |
| API responses | Status code + payload verification |
| Screenshots | Visual analysis only for UI test cases |
| Error logs | Full context around error keywords |
| LiteDB files | Binary — cannot be read, note as 'not analyzed (binary)' |

## Strict Analysis Standards (MANDATORY)

### Describe only what you see
- Report ONLY what is explicitly present in the evidence files
- If a log shows 28 API calls, say "28 API calls observed in log at [timestamp]"
- If a file cannot be read (binary, image, DB), say "not analyzed (binary file)" — do NOT infer content

### Zero assumptions
- NEVER assume what evidence "probably" shows or "likely" means
- NEVER extrapolate from one evidence file to make claims about another
- NEVER claim a behavior exists in untested scenarios based on tested ones
- If evidence is missing for a test case, mark it as MISSING — do not fill gaps with reasoning

### Separate observation from interpretation
- OBSERVATION (fact): "Log shows zero /time-entries calls between 18:52:56 and 18:53:15"
- INTERPRETATION (inference): "This suggests the suppression is working"
- Always label which is which in findings

### Scope conclusions to evidence
- Every conclusion must cite the specific evidence file and line/timestamp
- If a finding was observed in 2/8 attempts, say exactly "2/8 attempts" — do not generalize
- Do NOT say "pre-existing condition" unless evidence from before the PR exists
- Do NOT say "also happens under normal conditions" unless normal conditions were tested

### Acknowledge gaps honestly
- If you cannot read a file, say so explicitly
- If evidence is ambiguous, present both possible readings
- NEVER fill knowledge gaps with speculation presented as fact

## Efficiency Rules
- Do NOT read full log files — scan for keywords only
- Image analysis only for specific UI expected results
- Overwrite reports with updated timestamps
- No chat — write files and stop
