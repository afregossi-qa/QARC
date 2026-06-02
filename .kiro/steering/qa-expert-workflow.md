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
- Create evidence subfolders: `3_Evidence/localstate/`, `3_Evidence/external/`, `3_Evidence/screenshots/`, `3_Evidence/manual/`
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
- **Referenced Documents** (CRITICAL): After fetching the main ticket and all linked tickets, scan ALL text (description, comments, attachment names) for document references. Extract and read ANY linked resource:
  - **Confluence pages**: URLs matching `*.atlassian.net/wiki/*` or `*.atlassian.net/spaces/*` → use `confluence_get_page`
  - **Google Docs/Sheets**: URLs matching `docs.google.com/*` or `sheets.google.com/*` → use `web_fetch` to retrieve content
  - **Figma/design links**: URLs matching `figma.com/*` → note as design reference (cannot fetch, but document the link)
  - **Swagger/API docs**: URLs matching `*/swagger/*` or `*/api-docs/*` → use `web_fetch` to retrieve API contract
  - **IDEA/Polaris links**: URLs matching `*.atlassian.net/jira/polaris/*` → note the IDEA reference
  - **Azure DevOps wiki/docs**: URLs matching `*.visualstudio.com/*wiki*` → use `web_fetch`
  - **Any other URL** in description or comments that appears to be a requirements/design/spec document → attempt `web_fetch`
  
  Do NOT do a separate Confluence search. Instead, follow the references that already exist in the ticket data. These linked documents are the authoritative source — they contain PRDs, design specs, API contracts, and acceptance criteria that the Jira description often only summarizes.
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
Write to Expert/ folder following the EXACT format defined in `@expert-output-templates.md`:
- `logic_explanation.md` — Must include: Ticket Overview table, Feature Summary, Architecture & Data Flow, technical section, Gap Analysis (numbered), Linked Ticket Analysis, Risk Assessment table, Testing Focus Areas
- `manual_input.md` — Must include: Purpose statement, checkbox General Observations (pre-filled confirmed + open questions with blanks), Simple Flow with observation prompts, Full Flows (A/B/C) with blank fields, Clarifications Needed, Screenshots/Evidence table
- `test_plan_PENDING.md` — Must include: Notes (pre-filled findings), Description with Scope/Out of Scope, Test Areas with TC# numbering (Area.Number format), Test Environment Requirements table, Dependencies table

**FORMAT IS MANDATORY** — Read `@expert-output-templates.md` before generating any output file.

## AIO Integration Rules
- Append: Mark cases as `[AIO Existing]`
- Adapt: Mark as `[AIO Adapted]`, preserve original key reference
- Never auto-sync back to AIO (that's AIO-Direct-Agent's job)

## Efficiency Rules
- PR diffs >500 lines: logic blocks only
- AIO cases: max 30, note remainder
- No summaries or chat — write files and stop
