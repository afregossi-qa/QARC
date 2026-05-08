# Project Structure

## Repository Organization

### Root Level
- `{year}/{quarter}/Version {number}/`: Quarterly grouping of sprint version folders
- `POS-{ticket-number} - {description}/`: Feature-specific test documentation folders (inside version folders, or at root for active/test tickets)
- `Documentation/`: General framework documentation (not ticket-specific)
- `SUMMARY.md`: Overall QA analysis and findings summary
- `*_Parallel_Testing_Guide.md`: Integration testing guides for related features

### Quarterly & Version Folder Convention
Tickets are organized by year, quarter, and sprint version:
```
2026/
└── Q1/
    └── Version 225/
        ├── POS-9967 - Implement Delta based config download - Employee and Job Title/
        ├── POS-9969 - Implement Delta based config download - Terminal Config Lookup/
        ├── POS-9970 - Implement Delta based config download - Menu Lookup/
        └── POS-10302 - Implement Delta based config download - SharedEmployee/
```
- Create `{year}/{quarter}/` folders as needed (e.g., `2026/Q2/`)
- Create a `Version {number}/` folder inside the quarter for each sprint
- Move all sprint tickets into the corresponding version folder
- Hook glob patterns (`**/Expert/`, `**/Validator/`, etc.) work at any nesting depth — no automation changes needed
- Test or scratch tickets can remain at workspace root

## Feature Documentation Structure

Each feature folder follows this pattern:
```
POS-{ticket-number} - {description}/
├── .state.json             # Pipeline state tracker (see lifecycle-states.md)
├── 1_Expert/               # QA Expert agent outputs (Phase 1)
│   ├── logic_explanation.md
│   ├── manual_input.md
│   └── test_plan_POS-{ticket}.md
├── 2_Validator/            # QA Validator agent outputs (Phase 2)
│   ├── FINAL_TEST_CASES_POS-{ticket}_PENDING.md
│   ├── POS-{ticket}_TCMS_Import.csv
│   └── FINAL_QA_SUMMARY.md
├── 3_Evidence/             # Raw execution data (Phase 3)
│   └── *.json, *.png, *.jpg
├── 4_Reviewer/             # QA Evidence Reviewer outputs (Phase 4)
│   ├── EXECUTION_FINDINGS_POS-{ticket}.md
│   └── FINAL_CLOSURE_REPORT_POS-{ticket}.md
├── 5_Snapshots/            # Auto-generated rollback copies
├── 6_Automation/           # Ticket-scoped test scripts (optional)
│   ├── scripts/
│   └── logs/
├── AIO_SYNC_LOG.md         # AIO Tests sync state (generated)
├── PROGRESS_TRACKER.md     # Live status tracker (updated each phase)
├── REMEDIATION_LOG.md      # Iteration tracking for remediation cycles (generated)
├── QA_DASHBOARD.md         # Final lifecycle dashboard (generated at STABLE)
└── SUMMARY.md              # Executive summary (generated at STABLE)
```

**Key rules**:
- `.state.json` tracks pipeline phase (see @lifecycle-states.md for schema).
- `.phase-trigger.md` is a temporary trigger file created by advance-phase.ps1 (auto-deleted by hook).
- `1_Expert/` holds logic analysis, manual input, and test plans.
- `2_Validator/` holds finalized test cases, CSV exports, and QA summaries.
- `3_Evidence/` holds only raw data (JSON logs, screenshots, API captures).
- `4_Reviewer/` holds execution findings and closure reports.
- `5_Snapshots/` holds timestamped copies of files before agent overwrites (auto-managed by hook) and iteration-labeled baselines (e.g., `_BASELINE_R1.md`) created during remediation cycles.
- `6_Automation/` holds ticket-scoped test scripts and execution logs (optional).
  - `REGRESSION_TEST_CASES_POS-{ticket}.md` — Regression candidacy analysis from Regression Architect
  - `automation_steps_POS-{ticket}.md` — Arrange/Act/Assert step mappings from Step Translator
  - `Automation_Blueprint_POS-{ticket}.md` — Automation blueprint (optional, can also be at ticket root)
  - `scripts/` — Executable test scripts (Python/Java)
  - `logs/` — Execution logs and results
- `PROGRESS_TRACKER.md` is a live status file updated at each pipeline phase transition.
- `QA_DASHBOARD.md` and `SUMMARY.md` are final artifacts generated only when ticket reaches STABLE.
- Ticket root holds cross-cutting files (AIO sync log, progress tracker, remediation log, state, phase trigger).

## File Naming Conventions

### Suffix Conventions
| Suffix | Meaning | Next Action |
|--------|---------|-------------|
| `_PENDING` | Agent-generated, awaiting human review | Human reviews and renames to `_OK` |
| `_OK` | Human-approved, ready for next pipeline stage | Triggers next agent hook |
| `_API` | Exported/synced to external system (AIO Tests) | Terminal state |
| `_REMEDIATE` | Marked for remediation cycle | Triggers remediation hook |

### Approval Workflow
1. Agent generates `FINAL_TEST_CASES_POS-XXXX_PENDING.md`
2. Human reviews, makes edits, renames to `FINAL_TEST_CASES_POS-XXXX_OK.md`
3. Hook detects `_OK` suffix and triggers next stage
4. After AIO sync, file becomes `FINAL_TEST_CASES_POS-XXXX_API.md`

### Alternative: State-Based Workflow
Instead of renaming files, update `.state.json` to advance phases:
1. Agent generates file, sets state to `VALIDATOR_PENDING`
2. Human reviews, updates state to `VALIDATOR_OK`
3. Dashboard agent reads state to determine pipeline position

### Expert/ folder

#### logic_explanation.md
Contains:
- Ticket summary and requirements
- Implementation analysis (PR reviews)
- Logic gaps and potential errors
- Requirements vs implementation alignment
- Acceptance criteria coverage
- Developer notes and clarifications

#### manual_input.md
Template for QA testers to document:
- Test environment setup
- Additional test cases discovered during exploratory testing
- Manual testing observations and notes

#### test_plan_POS-{ticket}.md
Comprehensive test plan including:
- Test strategy and scope
- Test environment setup
- Test cases organized by category
- Test coverage matrix
- Blocked tests requiring clarification
- Risk assessment
- Test execution plan
- Sign-off criteria

## Test Case Organization

Test cases are organized into categories:
1. **Independent Sync Functionality**: Entity-specific sync validation
2. **Full Sync Behavior**: Complete dataset synchronization
3. **Incremental Sync Behavior**: Delta-time filtering
4. **Fallback Mechanism**: Error recovery and retry logic
5. **Entity-Specific Scenarios**: Business logic validation
6. **Permission Cache Consistency**: Security and access control
7. **Parallel Testing**: Integration with related features
8. **Error Handling**: Negative testing and edge cases
9. **Data Integrity**: Data consistency and correctness
10. **Boundary Conditions**: Edge cases and limits
11. **Regression Testing**: Existing functionality validation

## Test Case Naming Convention
- Format: `TC-{number}: {description}`
- Priority: P0 (Critical), P1 (High), P2 (Medium)
- Type: Functional, Integration, Performance, Regression, Security

## Parallel Testing
Related features must be tested together when they:
- Share infrastructure (sync tasks, repositories)
- Contribute to same caches (permission evaluation)
- Affect same business processes (employee synchronization)

Example: POS-9967 and POS-10302 must be tested in parallel because they share the employee synchronization task.

## Documentation Standards

### Logic Gap Identification
Gaps are categorized by severity:
- **CRITICAL**: Must address before production (e.g., deleted entity handling)
- **MEDIUM**: Should address, potential issues (e.g., timezone handling)
- **LOW**: Nice to have, minor improvements (e.g., pagination)

### Blocked Tests
Tests requiring clarification are marked with:
- **Blocker**: Specific question or missing specification
- **Action**: Escalation path (development team, product owner)
- **Recommendation**: Suggested approach or solution

### Risk Assessment
Risks are categorized as:
- **High Risk**: Critical business impact, security concerns
- **Medium Risk**: Potential issues, edge cases
- **Low Risk**: Minor concerns, well-tested patterns
