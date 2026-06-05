---
description: Full file naming rules, placement conventions, and test case organization
inclusion: fileMatch
fileMatchPattern: "**/1_Expert/**,**/2_Validator/**,**/3_Evidence/**,**/4_Reviewer/**,**/5_Snapshots/**,**/6_Automation/**"
---

# Project Structure — Full Details

## Repository Organization

### Root Level
- `{year}/{quarter}/Version {number}/`: Quarterly grouping of sprint version folders
- `{TICKET_ID} - {description}/`: Feature-specific test documentation folders (TICKET_ID is the full Jira key, e.g., POS-9967, ACV2-642)
- `Documentation/`: General framework documentation (not ticket-specific)

### Quarterly & Version Folder Convention
```
2026/
└── Q1/
    └── Version 225/
        ├── PROJ-4567 - Implement feature - Module A/
        └── PROJ-5678 - Implement feature - Module Name/
```
- Create `{year}/{quarter}/` folders as needed
- Create a `Version {number}/` folder inside the quarter for each sprint
- Hook glob patterns (`**/Expert/`, `**/Validator/`, etc.) work at any nesting depth
- Test or scratch tickets can remain at workspace root

## File Placement Rules

### MUST go in 1_Expert/
- `logic_explanation*.md`
- `test_plan*.md`
- `manual_input*.md`
- `*_analysis*.md`

### MUST go in 2_Validator/
- `FINAL_TEST_CASES*.md`
- `*_TCMS_Import.csv`
- `*_PENDING.md`, `*_OK.md`, `*_API.md`

### MUST go in 3_Evidence/
- `*.json` (API responses, logs)
- `*.png`, `*.jpg` (screenshots)
- `EVIDENCE_READY.md`
- `EVIDENCE_GAP_REPORT.md`

### MUST go in 4_Reviewer/
- `EXECUTION_FINDINGS*.md`
- `FINAL_CLOSURE_REPORT*.md`
- `*_REMEDIATE.md`

### ALLOWED in 5_Snapshots/
- Any file (timestamped backup copies of agent outputs)
- Iteration-labeled baselines (e.g., `_BASELINE_R1.md`)

### ALLOWED in 6_Automation/
- `REGRESSION_TEST_CASES_{TICKET_ID}.md`
- `automation_steps_{TICKET_ID}.md`
- `Automation_Blueprint_{TICKET_ID}.md`
- `scripts/*.py`, `scripts/*.java`
- `logs/*`

## Expert/ Folder Contents

### logic_explanation.md
- Ticket summary and requirements
- Implementation analysis (PR reviews)
- Logic gaps and potential errors
- Requirements vs implementation alignment
- Acceptance criteria coverage

### manual_input.md
- Test environment setup
- Additional test cases from exploratory testing
- Manual testing observations and notes

### test_plan_{TICKET_ID}.md
- Test strategy and scope
- Test cases organized by category
- Test coverage matrix
- Blocked tests requiring clarification
- Risk assessment and sign-off criteria

## Test Case Organization

Categories:
1. Independent Sync Functionality
2. Full Sync Behavior
3. Incremental Sync Behavior
4. Fallback Mechanism
5. Entity-Specific Scenarios
6. Permission Cache Consistency
7. Parallel Testing
8. Error Handling
9. Data Integrity
10. Boundary Conditions
11. Regression Testing

## Test Case Naming
- Format: `TC-{number}: {description}`
- Priority: P0 (Critical), P1 (High), P2 (Medium)
- Type: Functional, Integration, Performance, Regression, Security

## Parallel Testing
Related features must be tested together when they:
- Share infrastructure (sync tasks, repositories)
- Contribute to same caches (permission evaluation)
- Affect same business processes

## Documentation Standards

### Logic Gap Severity
- **CRITICAL**: Must address before production
- **MEDIUM**: Should address, potential issues
- **LOW**: Nice to have, minor improvements

### Blocked Tests
- **Blocker**: Specific question or missing specification
- **Action**: Escalation path
- **Recommendation**: Suggested approach

### Risk Assessment
- **High Risk**: Critical business impact, security concerns
- **Medium Risk**: Potential issues, edge cases
- **Low Risk**: Minor concerns, well-tested patterns
