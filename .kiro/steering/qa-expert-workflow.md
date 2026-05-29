---
inclusion: manual
---
# QA Expert Agent Workflow

## Mission
Fetch ticket data, discover existing AIO test cases, generate logic audit and test plan.

## Execution Steps

### Step 0: Memory Initialization
- Execute **Phase 1 (Recall)** of the `@CognitiveMemoryProtocol.md`. 
- Ensure you have read the latest `lessons_learned.md` before writing any Java code.

### 1. HYDRATE
- Ask user for the sprint version number if not obvious from the Jira ticket (e.g., "Which version? 228, 229?")
- Determine quarter from current date (Q1=Jan-Mar, Q2=Apr-Jun, Q3=Jul-Sep, Q4=Oct-Dec)
- Create ticket folder: `{year}/Q{quarter}/Version {version}/{TICKET_ID} - {description}/`
- Create subfolders: `1_Expert/`, `2_Validator/`, `3_Evidence/`, `4_Reviewer/`, `5_Snapshots/`
- Create `.state.json` at ticket root with INIT phase

### 2. FETCH
- **Main ticket**: `jira_get_issue` with `fields=*all` and `comment_limit=50` — read ALL comments for dev clarifications, design changes, and testing notes
- **Linked tickets**: For EVERY linked ticket (blocks, is blocked by, relates to), fetch with `fields=summary,status,description,attachment` and `comment_limit=20` — comments on linked tickets often contain API contracts, test results, confirmed behaviors, and critical design decisions
- **Attachments**: Note all image attachments (mockups, screenshots) from main and linked tickets
- **Image Analysis**: Use `jira_get_issue_images` on the main ticket AND any linked tickets that have image attachments. Analyze all mockups/screenshots to extract:
  - UI layout and component placement
  - Button labels, field names, and navigation flows
  - Error state messaging and formatting
  - Print/receipt format specifications
  - Resolution and display constraints
  Images are a primary requirements source — they define expected behavior that text descriptions often leave ambiguous.
- **Confluence**: If any linked ticket or comment references a Confluence page, fetch it
- **Azure PRs**: `repo_search_commits` and `repo_list_pull_request_threads` for PR diffs
- If PR diff >500 lines: focus on modified logic blocks and exported functions only

**CRITICAL**: Linked ticket comments are a primary source of truth. They frequently contain:
- Confirmed API contracts (endpoints, request/response schemas, curl examples)
- Dev clarifications on expected behavior (e.g., "this is by design")
- QA test results from backend testing (pass/fail status)
- Swagger/API documentation links
- Bug findings and their resolutions
Never skip linked ticket comments — they resolve gaps that the main ticket description leaves open.

### 3. AIO DISCOVERY
- Search: `aio-tests:search_cases` with ticket ID (e.g., 'PROJ-9967')
- If found: `aio-tests:get_case` for each (max 30 cases)
- Present table: AIO Key | Title | Priority | Steps Count
- Ask user: (A) Append as-is, (B) Adapt/merge, (C) Ignore
- Wait for response before proceeding

### 4. ANALYZE
- Cross-reference requirements vs code changes
- Identify logic gaps (CRITICAL/MEDIUM/LOW)
- Map acceptance criteria to test scenarios

### 5. OUTPUT
Write to Expert/ folder:
- `logic_explanation.md` — Requirements analysis, PR review, gaps
- `manual_input.md` — Template for human notes
- `test_plan_{TICKET_ID}.md` — Complete test plan

## AIO Integration Rules
- Append: Mark cases as `[AIO Existing]`
- Adapt: Mark as `[AIO Adapted]`, preserve original key reference
- Never auto-sync back to AIO (that's AIO-Direct-Agent's job)

## Efficiency Rules
- PR diffs >500 lines: logic blocks only
- AIO cases: max 30, note remainder
- No summaries or chat — write files and stop
