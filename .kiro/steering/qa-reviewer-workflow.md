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
- List ALL files in `Evidence/` including subfolders (`manual/`, `localstate/`, `external/`, `screenshots/`)
- Read all evidence regardless of naming convention — use content-based matching to map to test cases
- Apply Head/Tail rule: first 50 + last 50 lines for logs >100 lines
- Scan for keywords: Error, Fail, 200, 500, Exception
- Cross-reference with expected results from `Validator/FINAL_TEST_CASES`

Note: This workflow is triggered via the **"Validate Evidence & Review"** hook (userTriggered). The hook auto-detects the ticket from the user's active editor file. It can be re-triggered multiple times — each run produces a fresh analysis of ALL current evidence and overwrites previous findings.

### 2b. IMAGE ANALYSIS
- Scan the `3_Evidence/screenshots/` folder for image files: *.png, *.jpg, *.jpeg, *.gif, *.bmp, *.webp
- For each image found:
  - Use the MCP tool `extract_image_from_file` (from image-extractor server) to read the image as base64
  - Describe what is visually present (UI state, error dialogs, data displayed, status bar timestamps)
  - Correlate timestamps visible in screenshots with log entries when possible
  - Map the screenshot to the corresponding test case based on filename or folder structure
  - Record observations in findings using format: `[IMG: filename.png] Observation: ...`
- If an image cannot be read or is corrupted, note: `[IMG: filename.png] NOT ANALYZED — file unreadable`
- Do NOT infer behavior beyond what is visually shown in the image
- **IMPORTANT**: Use `extract_image_from_file` MCP tool — NOT `read_file` (which rejects binary content)

### 3. OUTPUT
Write to Reviewer/ folder:
- `EXECUTION_FINDINGS_{TICKET_ID}.md` — Test results, pass/fail status, issues found
- `FINAL_CLOSURE_REPORT_{TICKET_ID}.md` — Final verdict, recommendations, sign-off

### 3a. QA REVIEWER ATTRIBUTION (MANDATORY)
In both EXECUTION_FINDINGS and FINAL_CLOSURE_REPORT, the header field **"QA Reviewer"** MUST display TWO roles:
- The **human QA engineer** who is supervising and validating the AI-driven process
- The **AI agent** that performed the evidence analysis

Format:
```
**QA Reviewer:** {Human Name} (QA Supervisor) | AI Evidence Reviewer Agent
```

To determine the human QA supervisor:
1. Check the Jira ticket assignee (via `mcp_atlassian_jira_get_issue`)
2. If no assignee, use the reporter
3. If neither available, use "QA Team"

This ensures the closure report posted to Jira properly attributes ownership to the human QA who validated the process.

## Evidence Analysis Rules
| Evidence Type | Analysis Method |
|---------------|-----------------|
| JSON logs | Keyword scan + structure validation |
| API responses | Status code + payload verification |
| Screenshots/Images | **MANDATORY** — use `extract_image_from_file` MCP tool to read each image, describe UI state, text, timestamps, values |
| Error logs | Full context around error keywords |
| LiteDB files (.db) | **MANDATORY** — run `& "Tools/litedb-query.ps1" "<path>"` then query collections. Handles v4 and v5 automatically. NEVER skip .db files. |

### LiteDB Tool Quick Reference
```powershell
# List collections (auto-detects v4 or v5)
& "<workspace>/Tools/litedb-query.ps1" "<db-path>"

# Query first N documents from a collection
& "<workspace>/Tools/litedb-query.ps1" "<db-path>" <Collection> <limit>

# Fallback: raw binary string extraction
& "<workspace>/Tools/litedb-query.ps1" "<db-path>" -Raw
```
The wrapper tries LiteDB v5 first, then v4, then raw extraction as last resort.

### Evidence Data Sampling in Reports (MANDATORY for .db and .json files)

When writing EXECUTION_FINDINGS or FINAL_CLOSURE_REPORT, you MUST include an **Evidence Data Sample** section showing actual data from evidence files. This provides validators and reviewers with concrete proof of the data state.

**Format for LiteDB evidence:**
```markdown
### Evidence Data Sample — {db_filename}

| _id | Field1 | Field2 | LastUpdate |
|-----|--------|--------|------------|
| value | value | value | timestamp |
| value | value | value | timestamp |
| value | value | value | timestamp |

*Source: `3_Evidence/localstate/{filename}` — {collection_name} collection ({total_count} documents, {shown_count} sampled)*
```

**Rules:**
- Show 3-5 representative documents per database file
- Include ALL key fields that are relevant to the test case being validated
- If comparing before/after states, show BOTH tables side-by-side with clear labels
- For large collections (>50 docs), note the total count and explain sampling criteria
- For JSON evidence: show the relevant response body or key fields inline as a code block
- Timestamp fields are critical — always include them for temporal validation

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
